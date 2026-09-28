FROM mcr.microsoft.com/devcontainers/python:1-3.11-bookworm

RUN rm -f /etc/apt/sources.list.d/yarn.list /etc/apt/sources.list.d/yarn.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends postgresql-client \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir "poetry>=2.5,<3"

ENV POETRY_VIRTUALENVS_IN_PROJECT=false
