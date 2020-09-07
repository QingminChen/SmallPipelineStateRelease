import base64
import json
import base64
import requests
import logging
import string
import base64
import fileinput
import logging
from datetime import datetime
from io import BytesIO
from azure.devops.connection import Connection
from msrest.authentication import BasicAuthentication
import azure
import pprint
import datetime
import pytz
import logging
logging.basicConfig(level=logging.DEBUG)

def notify_topic_subscriber(event, context):
    """Triggered from a message on a Cloud Pub/Sub topic.
    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.
    """
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    if pubsub_message=='ok':
         personal_access_token = 'kkrubziptxnvmkhxo7i5m5qjs6744i6kh6gotf73ksumbz4v7waq'
         organization_url = 'https://dev.azure.com/testinggcpuser'
         personal_access_token_bytes_url = personal_access_token.encode("ascii")
         credentials = BasicAuthentication('', personal_access_token)
         connection = Connection(base_url=organization_url, creds=credentials)
         release_client = connection.clients_v5_1.get_release_client()
         update_release_environment_response = release_client.update_release_environment(azure.devops.v5_1.release.models.ReleaseEnvironmentUpdateMetadata(comment="Test trigger API",status='inProgress'),'PipelineIntegrateWithGCPDeployment', 68, 119)