import json
import os
import uuid
from datetime import datetime, timezone

import boto3

table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])


def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }


def lambda_handler(event, context):
    #method = event.get("requestContext", {}).get("http", {}).get("method")
    method = (
    event.get("requestContext", {})
    .get("http", {})
    .get("method")
    or event.get("httpMethod") # Aceitar ambos payload
    )

    # Vai trazer as informações do dynamodb
    if method == "GET":
        result = table.scan() # Scan lê a tabela toda, se fosse algo grande seria melhor usar uma query
        return response(200, result.get("Items", []))
    
    # insere no dynamo db
    if method == "POST":
        body = json.loads(event.get("body") or "{}")
        # Cria a estrutura do item
        item = {
            "task_id": str(uuid.uuid4()),
            "title": body.get("title", "Sem título"),
            "status": body.get("status", "todo"),
            "created_at": datetime.now(timezone.utc).isoformat()
        }

        table.put_item(Item=item)
        return response(201, item)

    return response(405, {"message": "Method not allowed"})