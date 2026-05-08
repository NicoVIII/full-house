FROM oven/bun:1-alpine AS skir-gen
WORKDIR /app
COPY skir.yml ./
COPY skir-src/ ./skir-src/
RUN bunx skir@1.2 gen

FROM oven/bun:1-alpine AS frontend-builder
WORKDIR /app
COPY webfrontend/package.json webfrontend/bun.lock ./
RUN bun install --frozen-lockfile
COPY webfrontend/ .
COPY --from=skir-gen /app/webfrontend/src/skirout/ ./src/skirout/
RUN bun run build

FROM ghcr.io/gleam-lang/gleam:v1.16.0-erlang-alpine AS backend-builder
RUN apk add --no-cache build-base
WORKDIR /app
COPY backend/gleam.toml backend/manifest.toml ./
COPY backend/linting ./linting
RUN gleam deps download
COPY backend/ .
COPY --from=skir-gen /app/backend/src/driver/skirout/ ./src/driver/skirout/
RUN gleam export erlang-shipment

FROM erlang:27-alpine
WORKDIR /app
COPY --from=backend-builder /app/build/erlang-shipment ./
COPY --from=frontend-builder /app/dist ./static

ENV STATIC_DIR=/app/static
ENV DATABASE_PATH=/data/full_house.db
ENV PORT=80
VOLUME ["/data"]
EXPOSE 80
ENTRYPOINT ["./entrypoint.sh"]
CMD ["run"]
