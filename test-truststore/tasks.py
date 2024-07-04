import os

from robocorp import vault
from robocorp.tasks import task


@task
def access_vault():
    secret = vault.get_secret(os.getenv("SECRET_NAME", "test_truststore"))
    print("Secret name:", secret.name)
    print("Secret description:", secret.description)
    print("Secret keys:", secret.keys())
