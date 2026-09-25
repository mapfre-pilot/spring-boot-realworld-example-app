# Dockerfile del frontend TVA.
# Build Angular 21 (--configuration=pro) + nginx sirviendo el SPA.
# Los paquetes @mapfre-tech/* vienen del feed privado de Azure Artifacts:
# pasar el PAT en base64 como secreto de build (nunca como ARG/ENV):
#   docker build --secret id=npm_pat_b64,env=AZURE_ARTIFACTS_NPM_PAT_B64 ...
FROM node:22-alpine AS build

RUN corepack enable && corepack prepare pnpm@11.21.0 --activate

WORKDIR /app
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml .npmrc ./
RUN --mount=type=secret,id=npm_pat_b64 \
    R='//pkgs.dev.azure.com/devopsmapfre/devopsmapfre/_packaging/releases/npm' \
    && for p in "$R/registry/" "$R/"; do \
         echo "$p:username=devopsmapfre"; \
         echo "$p:_password=$(cat /run/secrets/npm_pat_b64)"; \
         echo "$p:email=npm requires email to be set but doesn't use the value"; \
       done > /root/.npmrc \
    && pnpm install --frozen-lockfile \
    && rm -f /root/.npmrc

COPY . .
RUN pnpm exec nx build tva --configuration=pro

FROM nginx:alpine

RUN apk add --no-cache jq

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY docker/entrypoint.sh /entrypoint.sh
COPY --from=build /app/dist/apps/tva/browser /usr/share/nginx/html

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
