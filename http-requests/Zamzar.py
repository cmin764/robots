import requests
from requests.auth import HTTPBasicAuth

from variables import api_base


def convert_file(path, *, target, api_key):
    with open(path, "rb") as stream:
        data_content = {"target_format": target}
        file_content = {"source_file": stream}
        res = requests.post(
            f"{api_base}/jobs",
            data=data_content, files=file_content,
            auth=HTTPBasicAuth(api_key, "")
        )
    res.raise_for_status()
    return res.json()
