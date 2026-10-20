# Dev container del BFF PGM (Spring Boot 3 / Java 21 / Maven) para Podman rootless. Sin descargas HTTPS en el build
# (Maven vía apt) para funcionar detrás de proxies con inspección TLS; CA corporativa opcional en ./certs/*.crt.
ARG BASE_IMAGE=eclipse-temurin:21-jdk-jammy
FROM ${BASE_IMAGE}
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8
COPY certs/ /usr/local/share/ca-certificates/pgm/
RUN find /usr/local/share/ca-certificates/pgm -type f ! -name '*.crt' -delete; update-ca-certificates \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates curl git unzip zip jq less procps sudo openssh-client maven \
    && rm -rf /var/lib/apt/lists/* \
    && for c in /usr/local/share/ca-certificates/pgm/*.crt; do [ -f "$c" ] && keytool -importcert -noprompt -trustcacerts \
         -cacerts -storepass changeit -alias "pgm-$(basename "$c" .crt)" -file "$c" || true; done \
    && groupadd --gid ${USER_GID} ${USERNAME} && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && mkdir -p /home/${USERNAME}/.m2 /workspaces /config && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME} /workspaces /config
ENV PGM_CONFIG_DIR=/config
USER ${USERNAME}
WORKDIR /workspaces
