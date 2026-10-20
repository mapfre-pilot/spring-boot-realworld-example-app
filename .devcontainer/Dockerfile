# Dev container de PGM (SPA Angular + BFF Spring Boot) para ejecutarse con Podman (rootless) desde VS Code Dev Containers.
# Imágenes parametrizables para redes sin acceso a Docker Hub (p. ej. public.ecr.aws o acrmapfredevops).
ARG BASE_IMAGE=eclipse-temurin:21-jdk-jammy
FROM ${BASE_IMAGE}

ARG MAVEN_VERSION=3.9.11
ARG MAVEN_URL=https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
ARG NODE_VERSION=22.12.0
ARG NODE_URL=https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl git xz-utils unzip zip jq less procps sudo openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Maven (sin wrapper en el repo) y Node 22 (Angular 19 / Nx) desde tarballs oficiales
RUN curl -fsSL "${MAVEN_URL}" | tar -xz -C /opt && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
    && curl -fsSL "${NODE_URL}" | tar -xJ -C /opt && ln -s /opt/node-v${NODE_VERSION}-linux-x64 /opt/node
ENV MAVEN_HOME=/opt/maven PATH=/opt/maven/bin:/opt/node/bin:${PATH}

# Usuario no root (Podman rootless: con --userns=keep-id coincide con el UID del host)
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && mkdir -p /home/${USERNAME}/.m2 /home/${USERNAME}/.npm /workspaces/pgm-config \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME} /workspaces

USER ${USERNAME}
WORKDIR /workspaces
