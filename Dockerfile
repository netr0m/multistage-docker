FROM python:3.9-slim AS base
ARG APP_ROOT=/app
ARG APP=$APP_ROOT/app.py
ARG VENV_PATH=/opt/venv
ARG POETRY_INSTALL_ARGS="--no-interaction --no-ansi"
ENV FLASK_APP=$APP \
    VENV_PATH=$VENV_PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=$APP_ROOT \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    DEBIAN_FRONTEND=noninteractive
ENV PATH="$VENV_PATH/bin:$PATH"

WORKDIR $APP_ROOT
CMD ["flask", "run", "--host=0.0.0.0"]

COPY pyproject.toml poetry.lock ./
COPY src .
COPY input ./input

# Install packages and dependencies
RUN apt-get update -qq && \
    apt-get install -qq --no-install-recommends unixodbc-dev g++ && \
    rm -rf "/var/cache/apt/*" "/var/lib/apt/lists/*"

RUN python -m venv $VENV_PATH

RUN pip install -q --upgrade pip && \
    pip install -q poetry && \
    poetry config virtualenvs.create false

RUN poetry install $POETRY_INSTALL_ARGS
