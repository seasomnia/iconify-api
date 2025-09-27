ARG ARCH=docker.1ms.run/amd64
ARG NODE_VERSION=18
ARG OS=bullseye-slim
ARG ICONIFY_API_VERSION=3.1.1r0
ARG SRC_PATH=./

#### Stage BASE ########################################################################################################
FROM docker.1ms.run/amd64/node:18-bullseye-slim AS base




# Install tools, create data dir, add user and set rights
RUN set -ex && \
    mkdir -p /data/iconify-api

WORKDIR /data/iconify-api

#### Stage iconify-api-install #########################################################################################
FROM base AS iconify-api-install
ARG SRC_PATH

# Copy package files, install dependencies
COPY ${SRC_PATH}*.json ./
RUN npm ci

# Copy src and icons
COPY ${SRC_PATH}src/ /data/iconify-api/src/
COPY ${SRC_PATH}icons/ /data/iconify-api/icons/

# Build API
RUN npm run build

#### Stage RELEASE #####################################################################################################
FROM iconify-api-install AS RELEASE
ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_REF
ARG ICONIFY_API_VERSION
ARG ARCH
ARG TAG_SUFFIX=default

LABEL org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.docker.dockerfile="Dockerfile" \
    org.label-schema.license="MIT" \
    org.label-schema.name="Iconify API" \
    org.label-schema.version=${BUILD_VERSION} \
    org.label-schema.description="Node.js version of api.iconify.design" \
    org.label-schema.url="https://github.com/iconify/api" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-url="https://github.com/iconify/api" \
    org.label-schema.arch=${ARCH} \
    authors="Vjacheslav Trushkin"

RUN rm -rf /tmp/*

# Env variables
ENV ICONIFY_API_VERSION=$ICONIFY_API_VERSION

# Expose the listening port of Iconify API
EXPOSE 3000

# Add a healthcheck (default every 30 secs)
HEALTHCHECK CMD curl http://localhost:3000/ || exit 1

CMD ["npm", "run", "start"]
