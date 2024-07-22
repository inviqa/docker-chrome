# syntax=docker/dockerfile:1.3-labs
FROM debian:bullseye-slim

RUN <<EOF
set -o errexit -o nounset
apt-get update -qq
apt-get upgrade -qq -y
DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
  ca-certificates \
  chromium \
  curl \
  dumb-init \
  socat \
  ttf-wqy-zenhei
useradd headless --shell /bin/bash --create-home
mkdir /data && chown -R headless:headless /data
apt-get auto-remove -qq -y
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

COPY root /

USER headless

EXPOSE 9222

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint.sh", "--user-data-dir=/data", "--disable-dev-shm-usage"]
CMD ["--disable-gpu", "--headless", "--no-sandbox" ]
