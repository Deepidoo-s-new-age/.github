#!/usr/bin/env python3
"""Post a PR recap to Talkspirit via Incoming Webhook (Dédé).

Reads TALKSPIRIT_WEBHOOK_URL from the environment (Cloud Agent secret).
Optional: TALKSPIRIT_ICON_URL.

Never mention internal vault tools or CTO OS in titles/content.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request

DEFAULT_AUTHOR = "Dédé"
DEFAULT_ICON = "https://cdn.jsdelivr.net/gh/Alexandre-Cornu/dede-avatar@main/dede-256.png"


def load_webhook_url() -> str:
    url = (os.environ.get("TALKSPIRIT_WEBHOOK_URL") or "").strip()
    if not url:
        sys.exit(
            "Missing TALKSPIRIT_WEBHOOK_URL. Set it as a Cloud Agent secret "
            "(Talkspirit Incoming Webhook URL)."
        )
    if not url.startswith("https://webhook.talkspirit.com/"):
        sys.exit("Invalid TALKSPIRIT_WEBHOOK_URL (expected https://webhook.talkspirit.com/…)")
    return url


def load_icon_url() -> str:
    icon = (os.environ.get("TALKSPIRIT_ICON_URL") or "").strip()
    return icon or DEFAULT_ICON


def send(
    *,
    title: str,
    content: str,
    url: str | None = None,
    display_name: str = DEFAULT_AUTHOR,
    contact_url: str | None = None,
    icon: str | None = None,
    thread_id: str | None = None,
) -> None:
    webhook = load_webhook_url()
    icon_url = icon or load_icon_url()
    payload: dict = {
        "title": title,
        "content": content,
        "contact": {
            "display_name": display_name,
            "icon": icon_url,
            "url": contact_url or icon_url,
        },
    }
    if url:
        payload["url"] = url
    if thread_id:
        payload["thread_id"] = thread_id

    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        webhook,
        data=body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            print(f"OK HTTP {resp.status}")
            raw = resp.read().decode("utf-8", errors="replace")
            if raw:
                print(raw)
    except urllib.error.HTTPError as e:
        err = e.read().decode("utf-8", errors="replace")
        sys.exit(f"HTTP {e.code}: {err or e.reason}")
    except urllib.error.URLError as e:
        sys.exit(f"Request failed: {e.reason}")


def main() -> None:
    p = argparse.ArgumentParser(description="Send a Talkspirit PR recap as Dédé")
    p.add_argument("--title", required=True)
    p.add_argument("--content", required=True)
    p.add_argument("--url", default=None, help="PR URL")
    p.add_argument("--author", default=DEFAULT_AUTHOR)
    p.add_argument("--icon", default=None)
    p.add_argument("--thread-id", default=None)
    args = p.parse_args()
    send(
        title=args.title,
        content=args.content,
        url=args.url,
        display_name=args.author,
        icon=args.icon,
        thread_id=args.thread_id,
    )


if __name__ == "__main__":
    main()
