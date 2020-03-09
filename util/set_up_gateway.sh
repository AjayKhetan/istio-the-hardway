#!/bin/bash

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export INGRESS_HOST=$(minikube ip)
env | grep INGRESS
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo "GATEWAY is $GATEWAY_URL"
echo "http://$GATEWAY_URL/productpage"
