ARG ERLANG_VERSION=27.3.4.11
ARG GLEAM_VERSION=v1.16.0

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

# Gleam stage
FROM ghcr.io/gleam-lang/gleam:${GLEAM_VERSION}-scratch AS gleam

FROM erlang:${ERLANG_VERSION}-alpine AS backend-builder
RUN apk add --no-cache build-base
COPY --from=gleam /bin/gleam /bin/gleam
WORKDIR /app
COPY backend/ .
RUN gleam deps download
COPY --from=skir-gen /app/backend/src/driver/skirout/ ./src/driver/skirout/
RUN gleam export erlang-shipment

FROM erlang:${ERLANG_VERSION}-alpine
COPY deploy/healthcheck.sh /app/healthcheck.sh
RUN \
  chmod +x /app/healthcheck.sh \
  && addgroup --system webapp \
  && adduser --system webapp -g webapp
USER webapp
COPY --from=backend-builder /app/build/erlang-shipment /app/
COPY --from=frontend-builder /app/dist /app/static

ENV STATIC_DIR=/app/static
ENV DATABASE_PATH=/data/full_house.db
ENV PORT=80
VOLUME ["/data"]
EXPOSE 80
WORKDIR /app
ENTRYPOINT ["./entrypoint.sh"]
CMD ["run"]
