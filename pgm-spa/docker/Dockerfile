# Equivalente abierto del arquetipo Angular (ARQT-ANGULAR-001): fuera de la red MAPFRE no hay acceso a las imágenes base de acrmapfredevops.
FROM node:22-alpine AS build
WORKDIR /workspace
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY . .
ARG CONFIGURATION=local
RUN npx nx build pgm-spa --configuration=${CONFIGURATION} --skip-nx-cache

FROM nginxinc/nginx-unprivileged:1.27-alpine
ENV BFF_URL=http://bff:8080
COPY docker/nginx.conf /etc/nginx/templates/default.conf.template
COPY --from=build /workspace/dist/pgm-spa/browser /usr/share/nginx/html
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:8080/monitoring/health || exit 1
