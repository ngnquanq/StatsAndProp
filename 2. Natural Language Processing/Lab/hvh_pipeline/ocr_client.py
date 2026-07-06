"""Client for the CLC Kim Hán Nôm API (tools.clc.hcmus.edu.vn).

The API mirrors what the web UI does (see /js/hannom.js on the site):
    image-upload -> structure-classification -> image-preprocessing -> image-ocr
plus separate-sentences for sentence segmentation.

The API is open, but rejects requests that don't look like they come from the
website ("Missing or invalid Bearer token" unless browser-like User-Agent,
Origin and Referer headers are sent). No login is needed. If that ever
changes, login() implements the site's form login (credentials.json next to
this file, or KHN_USERNAME / KHN_PASSWORD environment variables) and the
client retries authenticated automatically.
"""

import json
import os
import re
import time
from pathlib import Path

import requests

BASE = "https://tools.clc.hcmus.edu.vn"
API = BASE + "/api/web/clc-sinonom"
CREDENTIALS_FILE = Path(__file__).parent / "credentials.json"
RETRIES = 3


class OCRError(RuntimeError):
    pass


class RateLimited(OCRError):
    """Server said 'Truy cập bị từ chối' — burst quota hit; recovers in ~1 min."""


RATE_LIMIT_WAIT_S = 75
RATE_LIMIT_RETRIES = 6


class KimHanNomClient:
    def __init__(self):
        self.session = requests.Session()
        # The API rejects non-browser-looking requests, so mimic the web UI.
        self.session.headers.update({
            "User-Agent": (
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36"
            ),
            "Origin": BASE,
            "Referer": BASE + "/",
        })
        self._token = None

    # ---- auth -----------------------------------------------------------

    def _credentials(self):
        user = os.environ.get("KHN_USERNAME")
        pwd = os.environ.get("KHN_PASSWORD")
        if user and pwd:
            return user, pwd
        if CREDENTIALS_FILE.exists():
            creds = json.loads(CREDENTIALS_FILE.read_text())
            return creds["username"], creds["password"]
        raise OCRError(
            "No credentials: set KHN_USERNAME/KHN_PASSWORD or create credentials.json "
            '({"username": "...", "password": "..."})'
        )

    def login(self):
        user, pwd = self._credentials()
        login_page = self.session.get(BASE + "/account/login", timeout=30)
        login_page.raise_for_status()
        match = re.search(
            r'name="__RequestVerificationToken"[^>]*value="([^"]+)"', login_page.text
        )
        form = {"UserName": user, "Password": pwd}
        if match:
            form["__RequestVerificationToken"] = match.group(1)
        resp = self.session.post(BASE + "/account/login", data=form, timeout=30)
        resp.raise_for_status()
        self._token = self.session.cookies.get("token")
        if not self._token:
            raise OCRError("Login did not yield a token cookie — check credentials")
        return self._token

    def _headers(self):
        return {"Authorization": f"Bearer {self._token}"} if self._token else {}

    # ---- low-level calls --------------------------------------------------

    def _check(self, resp, what):
        try:
            model = resp.json()
        except ValueError:
            if "Bearer token" in resp.text:
                raise OCRError(f"{what}: auth required (Bearer token)")
            raise OCRError(f"{what}: non-JSON response ({resp.status_code}): {resp.text[:200]}")
        if not model.get("is_success"):
            message = json.dumps(model.get("message"), ensure_ascii=False)
            if "access_denied" in message:
                raise RateLimited(f"{what}: rate limited")
            raise OCRError(f"{what} failed: {message}")
        return model["data"]

    def _request(self, what, send):
        """Run `send()` (returns a Response) with retry/backoff/rate-limit handling."""
        last_err = None
        rate_limit_hits = 0
        attempt = 0
        while attempt < RETRIES:
            try:
                resp = send()
                if resp.status_code == 401:  # token expired — re-login once
                    self._token = None
                    self.login()
                    continue
                return self._check(resp, what)
            except RateLimited as err:
                last_err = err
                rate_limit_hits += 1
                if rate_limit_hits > RATE_LIMIT_RETRIES:
                    break
                print(f"  [rate limited — waiting {RATE_LIMIT_WAIT_S}s]")
                time.sleep(RATE_LIMIT_WAIT_S)  # doesn't count as a normal attempt
            except (requests.RequestException, OCRError) as err:
                last_err = err
                if "auth required" in str(err):  # server started demanding login
                    self.login()
                    continue
                attempt += 1
                time.sleep(2 ** attempt * 2)
        raise OCRError(f"{what}: giving up: {last_err}")

    def _post_json(self, endpoint, payload, what):
        return self._request(what, lambda: self.session.post(
            API + endpoint, json=payload, headers=self._headers(), timeout=180,
        ))

    # ---- pipeline steps ---------------------------------------------------

    def upload_image(self, path):
        data = Path(path).read_bytes()
        return self._request(f"image-upload {path}", lambda: self.session.post(
            API + "/image-upload",
            files={"image_file": (Path(path).name, data, "image/jpeg")},
            headers=self._headers(), timeout=180,
        ))["file_name"]

    def structure_classification(self, file_name):
        return self._post_json(
            "/structure-classification",
            {"file_name": file_name, "lang_type": 0, "ocr_id": 0, "reading_direction": 0},
            f"structure-classification {file_name}",
        )

    def preprocess(self, file_name):
        return self._post_json(
            "/image-preprocessing", {"file_name": file_name},
            f"image-preprocessing {file_name}",
        )["new_file_name"]

    def image_ocr(self, file_name, ocr_id, lang_type, reading_direction, font_type=1, epitaph=0):
        return self._post_json(
            "/image-ocr",
            {
                "ocr_id": ocr_id,
                "file_name": file_name,
                "lang_type": lang_type,
                "font_type": font_type,
                "reading_direction": reading_direction,
                "epitaph": epitaph,
            },
            f"image-ocr {file_name}",
        )

    def separate_sentences(self, text, ocr_id=1):
        return self._post_json(
            "/separate-sentences", {"text": text, "ocr_id": ocr_id},
            "separate-sentences",
        )

    # ---- one full page ------------------------------------------------------

    def ocr_page(self, image_path):
        """Run the full pipeline for one image; returns a result dict.

        Mirrors imageHanNomOCR() in the site's hannom.js: auto-classify, and
        if classification already returns OCR text (common document types),
        use it; otherwise preprocess + explicit image-ocr call.
        """
        file_name = self.upload_image(image_path)
        cls = self.structure_classification(file_name)

        if cls.get("is_sino_nom") is False:
            return {"image": str(image_path), "skipped": "not recognized as Sino-Nom", "lines": []}

        result = cls.get("result") or {}
        if cls.get("ocr_id") in (1, 2, 4, 5) and result.get("result_bbox"):
            raw = result.get("result_ocr_text") or []
            lines = [
                item[1][0] if isinstance(item, list) and isinstance(item[1], list) else item
                for item in raw
            ]
            return {
                "image": str(image_path),
                "classification": {k: cls.get(k) for k in ("ocr_id", "lang_type", "reading_direction")},
                "source": "structure-classification",
                "lines": [str(l) for l in lines],
                "result_bbox": result.get("result_bbox"),
            }

        ocr_id = cls.get("ocr_id") or 1
        is_epitaph = 1 if ocr_id == 5 else 0
        if ocr_id in (4, 5):
            ocr_id = 1
        new_file = self.preprocess(file_name)
        ocr = self.image_ocr(
            new_file,
            ocr_id=ocr_id,
            lang_type=cls.get("lang_type") or 1,
            reading_direction=cls.get("reading_direction") or 1,
            epitaph=is_epitaph,
        )
        return {
            "image": str(image_path),
            "classification": {k: cls.get(k) for k in ("ocr_id", "lang_type", "reading_direction")},
            "source": "image-ocr",
            "lines": [str(l) for l in (ocr.get("result_ocr_text") or [])],
            "result_bbox": ocr.get("result_bbox"),
        }
