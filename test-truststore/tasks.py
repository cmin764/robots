import requests
from robocorp.tasks import task


@task
def minimal_task():
    print(requests.get("http://ipv4.icanhazip.com").content)
