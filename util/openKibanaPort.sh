#!/bin/bash
KIBANA_PORT=$(kubectl -n logging get svc | grep kibana | awk '{split($5, port, "/"); print port[1]}')
KIBANA_POD_NAME=$(kubectl -n logging get pod | grep kibana | awk '{print $1}')
kubectl -n logging port-forward $KIBANA_POD_NAME $KIBANA_PORT:$KIBANA_PORT
