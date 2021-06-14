# Screeps Grafana K8s

kubectl create secret generic poller-envvars \
  --from-literal=GRAPHITE_PORT_8125_UDP_ADDR=statsd.screeps.svc.cluster.local \
  --from-literal=SCREEPS_EMAIL=... \
  --from-literal=SCREEPS_PASSWORD=... \
  --from-literal=SCREEPS_SHARD=... \
  --from-literal=SCREEPS_USERNAME=...

```
docker build .
<get final tag (aff013eaf3a7) from output >
docker tag aff013eaf3a7 docker.example.com/screeps-poller:aff013eaf3a7
docker push docker.example.com/screeps-poller:aff013eaf3a7
```

K8s

```
kubectl create secret docker-registry regcred --docker-server=docker.example.com --docker-username=<username> --docker-password=<password> --docker-email=<email> --namespace screeps
```

```
export TAG_NAME=8fec00b6e5b2
envsubst < poller-deployment.yaml | kubectl apply --namespace screeps -f - 
```
