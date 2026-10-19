# Equivalente abierto del arquetipo Angular (ARQT-ANGULAR-001): fuera de la red MAPFRE no hay acceso a las imágenes base de acrmapfredevops.
# NODE_IMAGE/NGINX_IMAGE: en la red MAPFRE, las imágenes de acrmapfredevops; fuera, Docker Hub (o un mirror como public.ecr.aws si Hub limita con 429).
ARG NODE_IMAGE=node:22-alpine
ARG NGINX_IMAGE=nginxinc/nginx-unprivileged:1.27-alpine
FROM ${NODE_IMAGE} AS build
WORKDIR /workspace
COPY package.json package-lock.json .npmrc ./
RUN npm ci --no-audit --no-fund
COPY . .
ARG CONFIGURATION=local
RUN npx nx build pgm-spa --configuration=${CONFIGURATION} --skip-nx-cache

FROM ${NGINX_IMAGE}
ENV BFF_URL=http://bff:8080
COPY docker/nginx.conf /etc/nginx/templates/default.conf.template
COPY docker/05-resolver.envsh /docker-entrypoint.d/05-resolver.envsh
COPY --from=build /workspace/dist/pgm-spa/browser /usr/share/nginx/html
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:8080/monitoring/health || exit 1
