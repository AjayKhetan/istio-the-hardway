#!/bin/bash
GRAFANA_PORT=$(kubectl -n istio-system get svc | grep grafana | awk '{split($5, port, "/"); print port[1]}' )
GRAFANA_POD_NAME=$(kubectl -n istio-system get pod | grep grafana | awk '{print $1}')
kubectl -n istio-system port-forward $GRAFANA_POD_NAME $GRAFANA_PORT:$GRAFANA_PORT
