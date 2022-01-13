ARG APP_ROOT=/app
ARG APP=$APP_ROOT/app.py
ARG VENV_PATH=$APP_ROOT/.venv
ARG POETRY_INSTALL_ARGS="--no-interaction --no-ansi"
ARG ODBC_DLL_PATH="/usr/lib/x86_64-linux-gnu/libodbc.so.2"
ARG LTDL_DLL_PATH="/usr/lib/x86_64-linux-gnu/libltdl.so.7"

FROM python:3.9-slim AS base
ARG APP_ROOT \
    APP \
    VENV_PATH
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
COPY src ./
COPY input ./input

# Install packages
FROM base AS base-deps
ARG APT_INSTALL_ARGS="-qq --no-install-recommends -o Dpkg::Use-Pty=0"
## Install required OS packages
RUN apt-get update -qq && \
    apt-get install $APT_INSTALL_ARGS unixodbc-dev g++ && \
    rm -rf "/var/cache/apt/*" "/var/lib/apt/lists/*"
## Install Poetry
RUN pip install -q --upgrade pip && \
    pip install -q poetry && \
    poetry config virtualenvs.in-project true

### dev stage ###
FROM base-deps AS app-dev
ARG POETRY_INSTALL_ARGS
## Install dependencies
RUN poetry install $POETRY_INSTALL_ARGS

FROM base AS development
ARG VENV_PATH \
    ODBC_DLL_PATH \
    LTDL_DLL_PATH
## Copy required files from app-dev stage
COPY --from=app-dev $VENV_PATH $VENV_PATH
COPY --from=app-dev $ODBC_DLL_PATH $ODBC_DLL_PATH
COPY --from=app-dev $LTDL_DLL_PATH $LTDL_DLL_PATH
### END dev stage ###

### prod stage ###
FROM base-deps AS app-prod
ARG POETRY_INSTALL_ARGS
RUN poetry install $POETRY_INSTALL_ARGS --no-dev

FROM base AS production
ARG VENV_PATH \
    ODBC_DLL_PATH \
    LTDL_DLL_PATH
COPY --from=app-prod $VENV_PATH $VENV_PATH
COPY --from=app-prod $ODBC_DLL_PATH $ODBC_DLL_PATH
COPY --from=app-prod $LTDL_DLL_PATH $LTDL_DLL_PATH

USER 1000
### END prod stage ###
