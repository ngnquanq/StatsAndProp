#!/usr/bin/env python3
"""Upload one file to GCS using a GCE metadata-service access token."""

import argparse
import json
import mimetypes
import urllib.error
import urllib.parse
import urllib.request

METADATA_TOKEN_URL = "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token"
UPLOAD_URL = "https://storage.googleapis.com/upload/storage/v1/b/{bucket}/o?uploadType=media&name={name}"


def metadata_token():
    req = urllib.request.Request(METADATA_TOKEN_URL, headers={"Metadata-Flavor": "Google"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))["access_token"]


def upload(bucket, object_name, path):
    token = metadata_token()
    data = path.read_bytes()
    content_type = mimetypes.guess_type(path.name)[0] or "application/octet-stream"
    url = UPLOAD_URL.format(
        bucket=urllib.parse.quote(bucket, safe=""),
        name=urllib.parse.quote(object_name, safe="/"),
    )
    req = urllib.request.Request(
        url,
        data=data,
        method="POST",
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": content_type,
            "Content-Length": str(len(data)),
        },
    )
    with urllib.request.urlopen(req, timeout=300) as resp:
        return json.loads(resp.read().decode("utf-8"))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("bucket")
    parser.add_argument("object_name")
    parser.add_argument("path", type=__import__("pathlib").Path)
    args = parser.parse_args()
    result = upload(args.bucket, args.object_name, args.path)
    print(f"gs://{args.bucket}/{result['name']}")


if __name__ == "__main__":
    main()
