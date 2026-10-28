import os
from datetime import datetime, timezone

from fastapi import FastAPI, HTTPException
from google.cloud import storage
from pydantic import BaseModel

# app = FastAPI(title="GCP Files API")

# bucket_name = os.environ["BUCKET_NAME"]
# storage_client = storage.Client()
# bucket = storage_client.bucket(bucket_name)

app = FastAPI(title="GCP Files API")

project_id = os.environ["GOOGLE_CLOUD_PROJECT"]
bucket_name = os.environ["BUCKET_NAME"]

storage_client = storage.Client(project=project_id)
bucket = storage_client.bucket(bucket_name)

class TextFileRequest(BaseModel):
    filename: str
    content: str


@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "gcp-files-api"
    }


@app.get("/files")
def list_files():
    blobs = storage_client.list_blobs(bucket_name)

    return [
        {
            "name": blob.name,
            "size": blob.size,
            "updated": blob.updated.isoformat() if blob.updated else None
        }
        for blob in blobs
    ]


@app.post("/files", status_code=201)
def create_file(payload: TextFileRequest):
    filename = payload.filename.strip()

    if not filename:
        raise HTTPException(status_code=400, detail="filename cannot be empty")
    # Tratar nomes inválidos
    if filename.startswith("/") or ".." in filename:
        raise HTTPException(status_code=400, detail="invalid filename")

    blob = bucket.blob(filename)
    blob.upload_from_string(
        payload.content,
        content_type="text/plain; charset=utf-8"
    )

    return {
        "message": "file created",
        "name": filename,
        "created_at": datetime.now(timezone.utc).isoformat()
    }


@app.get("/files/{filename:path}")
def get_file(filename: str):
    blob = bucket.blob(filename)

    if not blob.exists():
        raise HTTPException(status_code=404, detail="file not found")

    return {
        "name": filename,
        "content": blob.download_as_text()
    }