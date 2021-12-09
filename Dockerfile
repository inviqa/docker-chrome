# syntax=docker/dockerfile:1.3-labs
FROM debian:bullseye-slim

RUN <<EOF
set -o errexit -o nounset -o pipefail
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
  ca-certificates \
  chromium \
  dumb-init \
  ttf-wqy-zenhei
useradd headless --shell /bin/bash --create-home
mkdir /data && chown -R headless:headless /data
EOF

USER headless

EXPOSE 9222

ENTRYPOINT ["/usr/bin/dumb-init", "--", \
            "/usr/bin/chromium", \
            "--disable-gpu", \
            "--headless", \
            "--no-sandbox", \
            "--disable-dev-shm-usage", \
            "--remote-debugging-address=0.0.0.0", \
            "--remote-debugging-port=9222", \
            "--user-data-dir=/data"]
