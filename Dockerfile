# syntax=docker/dockerfile:1.3-labs
FROM debian:bullseye-slim

RUN <<EOF
set -o errexit -o nounset
apt-get update -qq
apt-get upgrade -qq -y
DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
  ca-certificates \
  chromium \
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

ENTRYPOINT /usr/bin/dumb-init -- /bin/bash -c \
  '/usr/bin/chromium --disable-gpu --headless --no-sandbox --disable-dev-shm-usage --remote-debugging-port=9223 --user-data-dir=/data & \
  (wait-for 127.0.0.1:9222 && /usr/bin/socat -v TCP4-LISTEN:9222,fork,reuseaddr TCP4:127.0.0.1:9223) & \
  wait'
