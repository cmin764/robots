from robocorp.tasks import task


@task
def hello():
    for i in range(100):
        print(f"Hello World: {i}")
