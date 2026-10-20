# Dev container de la SPA PGM (Angular 19 + Nx, Node 22) para Podman rootless. Imagen base parametrizable.
ARG BASE_IMAGE=node:22-bookworm-slim
FROM ${BASE_IMAGE}
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl git procps sudo openssh-client \
    && rm -rf /var/lib/apt/lists/* \
    && (userdel -r node 2>/dev/null || true) \
    && groupadd --gid ${USER_GID} ${USERNAME} && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && mkdir -p /home/${USERNAME}/.npm /workspaces && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME} /workspaces
USER ${USERNAME}
WORKDIR /workspaces
