#!/usr/bin/env bash

UNIXTIME=$(date +%s)

docker build -f Dockerfile.prod -t repo.treescale.com/skoba/arrows:build-$UNIXTIME .
docker push repo.treescale.com/skoba/arrows:build-$UNIXTIME

helm upgrade -i --set image.tag=build-$UNIXTIME --wait --namespace default arrows ./chart
WEB_POD=$(kubectl get pods -l app.kubernetes.io/name=arrows-web --output=jsonpath={.items..metadata.name})
kubectl exec $WEB_POD mix ecto.migrate