# Dev container del BFF PGM (Spring Boot 3 / Java 21 / Maven 3.9) para Podman rootless. Imagen base parametrizable (ECR/acrmapfredevops).
ARG BASE_IMAGE=eclipse-temurin:21-jdk-jammy
FROM ${BASE_IMAGE}
ARG MAVEN_VERSION=3.9.11
ARG MAVEN_URL=https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl git unzip zip jq less procps sudo openssh-client \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL "${MAVEN_URL}" | tar -xz -C /opt && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
    && groupadd --gid ${USER_GID} ${USERNAME} && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && mkdir -p /home/${USERNAME}/.m2 /workspaces /config && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME} /workspaces /config
ENV MAVEN_HOME=/opt/maven PATH=/opt/maven/bin:${PATH} PGM_CONFIG_DIR=/config
USER ${USERNAME}
WORKDIR /workspaces
