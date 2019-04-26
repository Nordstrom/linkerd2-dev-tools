#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Please provide the tag as an argument"
  echo "For example: ./docker_tag_and_push.sh mytag"
fi

echo "Pushing to $1"

docker tag gcr.io/linkerd-io/controller:$1 gitlab-registry.nordstrom.com/gtm/linkerd-sandbox/controller:$1
docker push gitlab-registry.nordstrom.com/gtm/linkerd-sandbox/controller:$1

docker tag gcr.io/linkerd-io/proxy:$1 gitlab-registry.nordstrom.com/gtm/linkerd-sandbox/proxy:$1
docker push gitlab-registry.nordstrom.com/gtm/linkerd-sandbox/proxy:$1

docker tag gcr.io/linkerd-io/grafana:$1 gitlab-registry.nordstrom.com/gtm/linkerd-sandbox/grafana:$1
docker push gitlab-registry.nordstrom.com/gtm/linkerd-sandbox/grafana:$1

docker tag gcr.io/linkerd-io/web:$1 gitlab-registry.nordstrom.com/gtm/linkerd-sandbox/web:$1
docker push gitlab-registry.nordstrom.com/gtm/linkerd-sandbox/web:$1

