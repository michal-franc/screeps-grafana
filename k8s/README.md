# Screeps Grafana K8s

kubectl create secret generic poller-envvars \
  --from-literal=GRAPHITE_PORT_8125_UDP_ADDR=statsd.screeps.svc.cluster.local \
  --from-literal=SCREEPS_EMAIL=... \
  --from-literal=SCREEPS_PASSWORD=... \
  --from-literal=SCREEPS_SHARD=... \
  --from-literal=SCREEPS_USERNAME=...

```
export DOCKER_HOST=example.domain.com
docker build .
<get final tag (aff013eaf3a7) from output >
docker tag aff013eaf3a7 $DOCKER_HOST/screeps-poller:aff013eaf3a7
docker push $DOCKER_HOST/screeps-poller:aff013eaf3a7
```

K8s

```
export DOCKER_HOST=example.domain.com
kubectl create secret docker-registry regcred --docker-server=$DOCKER_HOST --docker-username=<username> --docker-password=<password> --docker-email=<email> --namespace screeps
```

```
export DOCKER_HOST=example.domain.com
export TAG_NAME=7f118df2e11fecbc8404f27c6edebf0084720f924506db913c5b6576f1722879
envsubst < poller-deployment.yaml | kubectl apply --namespace screeps -f - 
```
