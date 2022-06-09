import requests
from requests.auth import HTTPBasicAuth


def post_text(filename, api_key):
    with open(filename, "rb") as f:
        resp = requests.post(
            "https://sandbox.zamzar.com/v1/jobs", 
            data={"target_format": "txt"}, 
            files={"source_file": f}, 
            auth=HTTPBasicAuth(api_key, "")
        )
    resp.raise_for_status()
    return resp.json()
