#!/bin/bash
set -eux

if [[ -z "$1" ]]; then
  echo "No PromeCIeus url specified"
  exit 1
fi

podman pull ghcr.io/pyrra-dev/pyrra:main
podman rm -f pyrra-api pyrra-fs || true
podman run --rm -d \
  --name pyrra-api \
  --publish 9099:9099 \
  --net slirp4netns:allow_host_loopback=true \
  -ti ghcr.io/pyrra-dev/pyrra:main \
  api --prometheus-url=${1} --api-url=http://10.0.2.2:9444
podman run --rm -d \
  --name pyrra-fs \
  --publish 9444:9444 \
  --net slirp4netns:allow_host_loopback=true \
  -v $(pwd)/slo:/etc/pyrra:z \
  -v $(mktemp -d):/etc/prometheus/pyrra:z \
  -ti ghcr.io/pyrra-dev/pyrra:main \
  filesystem

echo "Pyrra for ${1} is available at http://localhost:9099"
