# Dockerfile público del frontend TVA.
# Build Angular 21 (--configuration=pro) + nginx sirviendo el SPA.
FROM node:22-alpine AS build

RUN corepack enable && corepack prepare pnpm@11.21.0 --activate

WORKDIR /app
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml .npmrc ./
COPY libs ./libs
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm exec nx build tva --configuration=pro

FROM nginx:alpine

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/apps/tva/browser /usr/share/nginx/html

EXPOSE 80
