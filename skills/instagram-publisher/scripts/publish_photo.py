#!/usr/bin/env python3
"""Publish a single public image URL to Instagram via Meta's official API."""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request


def post_form(url: str, data: dict[str, str]) -> dict:
    encoded = urllib.parse.urlencode(data).encode("utf-8")
    request = urllib.request.Request(url, data=encoded, method="POST")
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            body = response.read().decode("utf-8")
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise SystemExit(f"Meta API error {exc.code}: {body}") from exc
    except urllib.error.URLError as exc:
        raise SystemExit(f"Network error calling Meta API: {exc}") from exc

    try:
        return json.loads(body)
    except json.JSONDecodeError as exc:
        raise SystemExit(f"Meta API returned non-JSON response: {body}") from exc


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Publish a single image URL to Instagram."
    )
    parser.add_argument("--image-url", required=True, help="Publicly reachable image URL.")
    parser.add_argument("--caption", required=True, help="Instagram caption text.")
    parser.add_argument("--ig-user-id", default=os.environ.get("IG_USER_ID"))
    parser.add_argument("--access-token", default=os.environ.get("IG_ACCESS_TOKEN"))
    parser.add_argument(
        "--graph-version",
        default=os.environ.get("META_GRAPH_VERSION", "v24.0"),
        help="Meta Graph API version, e.g. v24.0.",
    )
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    if not args.ig_user_id:
        raise SystemExit("Missing IG user id. Set IG_USER_ID or pass --ig-user-id.")
    if not args.access_token:
        raise SystemExit("Missing access token. Set IG_ACCESS_TOKEN or pass --access-token.")
    if not args.image_url.startswith(("https://", "http://")):
        raise SystemExit("--image-url must be a public HTTP(S) URL.")

    base_url = f"https://graph.instagram.com/{args.graph_version}/{args.ig_user_id}"
    container_payload = {
        "image_url": args.image_url,
        "caption": args.caption,
        "access_token": args.access_token,
    }

    if args.dry_run:
        print(
            json.dumps(
                {
                    "dry_run": True,
                    "create_container_url": f"{base_url}/media",
                    "publish_url": f"{base_url}/media_publish",
                    "image_url": args.image_url,
                    "caption_length": len(args.caption),
                },
                indent=2,
            )
        )
        return 0

    container = post_form(f"{base_url}/media", container_payload)
    creation_id = container.get("id")
    if not creation_id:
        raise SystemExit(f"Container creation did not return an id: {container}")

    published = post_form(
        f"{base_url}/media_publish",
        {"creation_id": creation_id, "access_token": args.access_token},
    )

    print(json.dumps({"container": container, "published": published}, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
