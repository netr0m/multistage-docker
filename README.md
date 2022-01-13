# Docker Multistage Build Test
Brief test with multistage builds to see the effect on build size, etc.

```bash
$ docker-compose build
$ docker image ls test           
REPOSITORY   TAG            CREATED              SIZE
test         multi-venv     27 seconds ago       174MB
test         multi-poetry   About a minute ago   139MB
test         single         3 minutes ago        460MB
```

[`Dockerfile`](./Dockerfile) is a plain old Dockerfile, no stages.
[`poetry-ms.Dockerfile`](./poetry-ms.Dockerfile) is an attempt at a multistaged Dockerfile using Poetry to manage the virtual environment.
[`venv-ms.Dockerfile`](./venv-ms.Dockerfile) is another attempt at a multistaged Dockerfile. This one uses `venv` to manage the virtual environment.
