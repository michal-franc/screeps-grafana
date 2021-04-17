# Screeps Grafana K8s

kubectl create secret generic poller-envvars \
  --from-literal=GRAPHITE_PORT_8125_UDP_ADDR=statsd.screeps.svc.cluster.local \
  --from-literal=SCREEPS_EMAIL=... \
  --from-literal=SCREEPS_PASSWORD=... \
  --from-literal=SCREEPS_SHARD=... \
  --from-literal=SCREEPS_USERNAME=...

```
docker build .
<get final tag (a74d5db975d2) from output >
docker tag a74d5db975d2 docker.pedanticorderliness.com/screeps-poller:a74d5db975d2
docker push docker.pedanticorderliness.com/screeps-poller:a74d5db975d2
```

K8s

```
kubectl create secret docker-registry regcred --docker-server=docker.pedanticorderliness.com --docker-username=<username> --docker-password=<password> --docker-email=<email> --namespace screeps
```

```
export TAG_NAME=8fec00b6e5b2
envsubst < poller-deployment.yaml | kubectl apply --namespace screeps -f - 
```

