"""Lambda marker — writes a JSON marker to the data lake raw/ prefix (U3)."""
from __future__ import annotations

import json
import os
from datetime import datetime, timezone

import boto3

s3 = boto3.client("s3")


def handler(event, context):
    bucket = os.environ["DATA_LAKE_BUCKET"]
    prefix = os.environ.get("RAW_PREFIX", "raw").rstrip("/")
    dt = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    key = f"{prefix}/dt={dt}/lambda_marker.json"

    body = {
        "source": "lambda",
        "status": "ok",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "request_id": getattr(context, "aws_request_id", None),
        "event": event if isinstance(event, dict) else {"payload": str(event)},
    }

    s3.put_object(
        Bucket=bucket,
        Key=key,
        Body=json.dumps(body).encode("utf-8"),
        ContentType="application/json",
    )

    return {
        "statusCode": 200,
        "bucket": bucket,
        "key": key,
        "body": body,
    }
