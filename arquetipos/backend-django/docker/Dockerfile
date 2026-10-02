FROM acrmapfredevops.azurecr.io/mapfre/arch/ram/mapfre-django-base:3.11-slim AS builder

# Installing poetry
RUN pip install poetry

# Select /local as the working directory
WORKDIR /local

# Copy Poetry configuration files
ADD sources/pyproject.toml sources/poetry.lock* /local/

# Install dependencies
RUN --mount=type=secret,id=AZURE_ARTIFACTS_PW,env=AZURE_ARTIFACTS_PW \
    poetry config http-basic.azure username $AZURE_ARTIFACTS_PW
RUN poetry config virtualenvs.create false && poetry install --no-root --no-ansi

# Exhibition at port 8888
EXPOSE 8888

# Create an unprivileged user and group
RUN addgroup --gid 1000 appgroup && adduser --uid 1000 -ingroup appgroup --disabled-password appuser

# Change ownership of the working folder to non-root user
RUN chown -R appuser:appgroup /local

# Copy only the application code
COPY --chown=appuser:appgroup sources/ /local/

# Add Poetry-installed executables (e.g. celery) to the PATH
ENV PATH=/home/appuser/.local/bin:$PATH

# Switch to non-root user
USER appuser
