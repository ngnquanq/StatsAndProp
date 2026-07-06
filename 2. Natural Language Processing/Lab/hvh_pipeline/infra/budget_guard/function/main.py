"""Budget Pub/Sub kill switch for the HVH OCR GCE worker project.

The function is intentionally scoped by labels and a single TARGET_PROJECT. It
is idempotent: repeated budget notifications should only find fewer resources.
"""

import base64
import json
import os
from typing import Any, Dict, Iterable, Optional

import functions_framework
import google.auth
from google.auth.transport.requests import Request
import requests

CLOUD_PLATFORM_SCOPE = "https://www.googleapis.com/auth/cloud-platform"


def _env_bool(name: str, default: bool = False) -> bool:
    raw = os.environ.get(name)
    if raw is None:
        return default
    return raw.strip().lower() in {"1", "true", "yes", "y", "on"}


def _token() -> str:
    credentials, _ = google.auth.default(scopes=[CLOUD_PLATFORM_SCOPE])
    credentials.refresh(Request())
    return credentials.token


def _request(method: str, url: str, token: str, **kwargs: Any) -> Optional[Dict[str, Any]]:
    headers = kwargs.pop("headers", {})
    headers["Authorization"] = f"Bearer {token}"
    if "json" in kwargs:
        headers.setdefault("Content-Type", "application/json")
    response = requests.request(method, url, headers=headers, timeout=60, **kwargs)
    if response.status_code in {200, 201, 202}:
        return response.json() if response.content else {}
    if response.status_code == 204 or response.status_code == 404:
        return {}
    print(f"{method} {url} failed: {response.status_code} {response.text[:500]}")
    return None


def _labels_match(resource: Dict[str, Any]) -> bool:
    labels = resource.get("labels") or {}
    return labels.get("app") == "hvh-ocr"


def _delete_compute_instances(project: str, token: str) -> None:
    url = (
        f"https://compute.googleapis.com/compute/v1/projects/{project}"
        "/aggregated/instances?filter=labels.app%3Dhvh-ocr"
    )
    data = _request("GET", url, token) or {}
    for scoped in (data.get("items") or {}).values():
        for instance in scoped.get("instances", []):
            zone = instance["zone"].split("/")[-1]
            name = instance["name"]
            print(f"Deleting Compute Engine instance {zone}/{name}")
            _request(
                "DELETE",
                f"https://compute.googleapis.com/compute/v1/projects/{project}/zones/{zone}/instances/{name}",
                token,
            )


def _filestore_locations() -> Iterable[str]:
    raw = os.environ.get("TARGET_FILESTORE_LOCATIONS", "asia-southeast1-a")
    for location in raw.split(","):
        location = location.strip()
        if location:
            yield location


def _delete_filestore_instances(project: str, token: str) -> None:
    for location in _filestore_locations():
        url = f"https://file.googleapis.com/v1/projects/{project}/locations/{location}/instances"
        data = _request("GET", url, token) or {}
        for instance in data.get("instances", []):
            if not _labels_match(instance):
                continue
            name = instance["name"]
            print(f"Deleting Filestore instance {name}")
            _request("DELETE", f"https://file.googleapis.com/v1/{name}", token)


def _delete_bucket_objects(bucket: str, token: str) -> None:
    page_token = ""
    while True:
        url = f"https://storage.googleapis.com/storage/v1/b/{bucket}/o"
        params = {"versions": "true"}
        if page_token:
            params["pageToken"] = page_token
        data = _request("GET", url, token, params=params) or {}
        for obj in data.get("items", []):
            object_name = requests.utils.quote(obj["name"], safe="")
            generation = obj.get("generation")
            params = {"generation": generation} if generation else None
            _request(
                "DELETE",
                f"https://storage.googleapis.com/storage/v1/b/{bucket}/o/{object_name}",
                token,
                params=params,
            )
        page_token = data.get("nextPageToken", "")
        if not page_token:
            break


def _delete_gcs_buckets(project: str, token: str) -> None:
    data = _request("GET", "https://storage.googleapis.com/storage/v1/b", token, params={"project": project}) or {}
    for bucket in data.get("items", []):
        if not _labels_match(bucket):
            continue
        name = bucket["name"]
        print(f"Deleting labeled GCS bucket {name}")
        _delete_bucket_objects(name, token)
        _request("DELETE", f"https://storage.googleapis.com/storage/v1/b/{name}", token)


def _disable_billing(project: str, token: str) -> None:
    print(f"Disabling billing for project {project}")
    _request(
        "PUT",
        f"https://cloudbilling.googleapis.com/v1/projects/{project}/billingInfo",
        token,
        json={"billingAccountName": ""},
    )


def _budget_payload(cloud_event: Any) -> Dict[str, Any]:
    data = getattr(cloud_event, "data", None) or {}
    message = data.get("message", {}) if isinstance(data, dict) else {}
    encoded = message.get("data")
    if encoded:
        return json.loads(base64.b64decode(encoded).decode("utf-8"))
    if isinstance(data, dict):
        return data
    return {}


def _should_trigger(payload: Dict[str, Any]) -> bool:
    hard_limit = float(os.environ.get("HARD_LIMIT_USD", "100"))
    cost_amount = float(payload.get("costAmount", 0) or 0)
    budget_amount = float(payload.get("budgetAmount", hard_limit) or hard_limit)
    threshold = float(payload.get("alertThresholdExceeded", 0) or 0)
    print(
        "Budget notification: "
        f"costAmount={cost_amount}, budgetAmount={budget_amount}, "
        f"alertThresholdExceeded={threshold}"
    )
    return cost_amount >= hard_limit or threshold >= 1.0


@functions_framework.cloud_event
def handle_budget_alert(cloud_event: Any) -> str:
    target_project = os.environ["TARGET_PROJECT"]
    payload = _budget_payload(cloud_event)
    if not _should_trigger(payload):
        print("Budget notification is below the hard-stop threshold; no action taken.")
        return "below-threshold"

    token = _token()
    _delete_compute_instances(target_project, token)
    _delete_filestore_instances(target_project, token)

    if _env_bool("DELETE_GCS_BUCKETS", False):
        _delete_gcs_buckets(target_project, token)
    else:
        print("DELETE_GCS_BUCKETS is false; preserving labeled GCS buckets/artifacts.")

    if _env_bool("DISABLE_BILLING", True):
        _disable_billing(target_project, token)

    return "kill-switch-complete"
