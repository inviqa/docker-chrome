# syntax=docker/dockerfile:1.3-labs
FROM alpine:latest

RUN <<EOF
apk add --no-cache \
  ca-certificates \
  chromium \
  chromium-swiftshader \
  font-croscore \
  font-noto-cjk \
  font-noto-emoji \
  tini \
  ttf-dejavu \
  ttf-liberation \
  ttf-opensans
adduser -D -H headless
mkdir /data && chown -R headless:headless /data
EOF

USER headless

EXPOSE 9222

ENTRYPOINT ["/sbin/tini", "--", \
            "/usr/bin/chromium-browser", \
            "--disable-gpu", \
            "--headless", \
            "--no-sandbox", \
            "--disable-dev-shm-usage", \
            "--remote-debugging-address=0.0.0.0", \
            "--remote-debugging-port=9222", \
            "--user-data-dir=/data"]