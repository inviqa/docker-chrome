#!/bin/bash

set -o errexit
set -o nounset

/usr/bin/chromium --remote-debugging-port=9223 "$@" &
/usr/local/bin/wait-for 127.0.0.1:9223

/usr/bin/socat -v TCP4-LISTEN:9222,fork,reuseaddr TCP4:127.0.0.1:9223 &

wait -n
