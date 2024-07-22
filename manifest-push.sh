#!/bin/bash

set -e -o pipefail

echo "${DOCKER_REGISTRY_CREDS_PSW}" | docker login --username "${DOCKER_REGISTRY_CREDS_USR}" --password-stdin "${DOCKER_REGISTRY}"

for IMAGE in $(docker compose config --format json | jq -r 'try .services[].image'); do
    if [ -z "$IMAGE" ] || [ "$IMAGE" = null ]; then
        continue
    fi
    docker manifest rm "${IMAGE}" 2>/dev/null || true
    docker manifest create "${IMAGE}" "${IMAGE}-linux-amd64" "${IMAGE}-linux-arm64"
    docker manifest push "${IMAGE}"
    docker manifest rm "${IMAGE}"
done

for IMAGE in $(docker compose config --format json | jq -r 'try .services[].build.tags[]'); do
    if [ -z "$IMAGE" ] || [ "$IMAGE" = null ]; then
        continue
    fi
    docker manifest rm "${IMAGE}" 2>/dev/null || true
    docker manifest create "${IMAGE}" "${IMAGE}-linux-amd64" "${IMAGE}-linux-arm64"
    docker manifest push "${IMAGE}"
    docker manifest rm "${IMAGE}"
done
