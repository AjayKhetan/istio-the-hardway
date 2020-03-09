# Istio the hard way round 2 - working with Istio Routes

## Using the route demo

Starting from where we left off in [the install guide aka Istio the Hard way](https://www.linkedin.com/pulse/istio-hard-way-rick-hightower/). You may recall that we installed the sample Istio `bookinfo` application which consists of several microservices.

Let's walk through the [route demo](https://istio.io/docs/tasks/traffic-management/request-routing/).


#### Installed sample Istio application
```sh

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

```

The ***BookInfo Istio Demo application*** has the following microservices:

* Productpage Microservice
* Details Microservice
* Reviews Microservice
* Ratings Microservice


#### BookInfo Services

![image](https://user-images.githubusercontent.com/382678/76173604-08c26880-615e-11ea-86b5-47fa0a1cf6ec.png)


As you can see the ***Istio Bookinfo sample***  is made of the `Productpage`, `Details`, `Reviews` and `Ratings` microservices.

If you followed along with the first guide then you will have three versions  of the `Ratings`microservice.


> To illustrate the problem this causes, access the Bookinfo app’s /productpage in a browser and refresh several times. You’ll notice that sometimes the book review output contains star ratings and other times it does not. This is because without an explicit default service version to route to, Istio routes requests to all available versions in a round robin fashion. --[route demo](https://istio.io/docs/tasks/traffic-management/request-routing/)


First let's route all of the traffic to just v1 of the reviews microservices.
But before we do that. Let's peek around a bit.


#### Make sure Minikube is running, we are in the right context and the right namespace

```sh

## Is minikube running?
$ minikube status
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured

## Are we in the right namespace
$ kubectx minikube
Switched to context "minikube".


## Are we using the right namespace
$ kubens bookinfo
Context "minikube" modified.
Active namespace is "bookinfo".
```

#### Make sure our services are running

```sh
$ kubectl get pod
NAME                              READY   STATUS    RESTARTS   AGE
details-v1-74f858558f-z72cw       2/2     Running   0          3d20h
hello-world-c7598fbb5-2v4l2       2/2     Running   0          42h
productpage-v1-8554d58bff-p8cwp   2/2     Running   0          3d20h
ratings-v1-7855f5bcb9-m2rxl       2/2     Running   0          3d20h
reviews-v1-59fd8b965b-d6xml       2/2     Running   0          3d20h
reviews-v2-d6cfdb7d6-m58mw        2/2     Running   0          3d20h
reviews-v3-75699b5cfb-kt4hs       2/2     Running   0          3d20h
```

You may have to restart Minikube and/or change the context to minikube.
Refer to the first guide to see how to do this and the guides it points to regarding kubectl and minikube install and usage.


Recall that [we ran `minikube tunnel`](https://github.com/cloudurable/istio-the-hardway#minikube-tunnel-so-we-can-use-grafana-and-friends) to connect to the microservices [through the istio gateway](https://github.com/cloudurable/istio-the-hardway#setting-up-the-gateway).

#### See if minikube tunnel is running
```sh

ps -e | grep  minikube | grep tunnel | awk '{print $1}'

```

If the minikube tunnel is not running, start it.

#### Start the minikube tunnel cleanly

```sh

## Clean up any old minikube tunnel config
$ minikube tunnel -c

### Output
E0308 17:16:35.346896   71396 tunnel.go:51] error cleaning up: conflicting rule in routing table: 10.96/12           192.168.64.18      UGSc       bridge1       



## Start up a new minikube tunnel in its own terminal
$ minikube tunnel   
Status:
 machine: minikube
 pid: 71405
 route: 10.96.0.0/12 -> 192.168.64.18
 minikube: Running
 services: [istio-ingressgateway]
   errors:
   minikube: no errors
   router: no errors
   loadbalancer emulator: no errors
```

Next recall that we need to set up [the istio gateway environment variables](https://github.com/cloudurable/istio-the-hardway#setting-up-the-gateway) using `util/set_up_gateway.sh` from the first guide, shown below.


#### util/set_up_gateway.sh
```sh
#!/bin/bash

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export INGRESS_HOST=$(minikube ip)
env | grep INGRESS
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo "GATEWAY is $GATEWAY_URL"
echo "http://$GATEWAY_URL/productpage"

```

Thus we want to source this to get the `GATEWAY_URL` environment variable.

#### Source set_up_gateway.sh
```sh

$ pwd
/Users/richardhightower/istio/istio-1.4.5

$ source util/set_up_gateway.sh
INGRESS_PORT=30851
SECURE_INGRESS_PORT=31073
INGRESS_HOST=192.168.64.18
GATEWAY is 192.168.64.18:30851
http://192.168.64.18:30851/productpage

```

Now reload http://$GATEWAY_URL/productpage until you see three versions of reviews, one with black stars, one with red stars and one with no stars.

#### Black stars reviews
![Black Stars](https://user-images.githubusercontent.com/382678/76174030-d581d880-6161-11ea-83c8-faa5a9956c3c.png)

#### Red Stars reviews
![Red Stars](https://user-images.githubusercontent.com/382678/76174049-04984a00-6162-11ea-8ffc-0c2b208a11dc.png)

#### No Star reviews
![No Stars](https://user-images.githubusercontent.com/382678/76174061-209beb80-6162-11ea-9946-cab38bad18d6.png)




## Route all traffic to v1


Recall the goal of the initial step of the route demo.

> To route to one version only, you apply virtual services that set the default version for the microservices. In this case, the virtual services will route all traffic to v1 of each microservice. --[route demo](https://istio.io/docs/tasks/traffic-management/request-routing/)

#### samples/bookinfo/networking/virtual-service-all-v1.yaml routes all traffic to v1 of each microservice
```sh
kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml


### Output
virtualservice.networking.istio.io/productpage created
virtualservice.networking.istio.io/reviews created
virtualservice.networking.istio.io/ratings created
virtualservice.networking.istio.io/details created
```

#### samples/bookinfo/networking/virtual-service-all-v1.yaml

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: productpage
spec:
  hosts:
  - productpage
  http:
  - route:
    - destination:
        host: productpage
        subset: v1
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - route:
    - destination:
        host: ratings
        subset: v1
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: details
spec:
  hosts:
  - details
  http:
  - route:
    - destination:
        host: details
        subset: v1
---


```


Notice that `virtual-service-all-v1.yaml` changes the `spec->http->route->destination->`<name of microservice>`->subset` to `v1` for each microservice.

To see that this is working go to `http://192.168.64.18:30851/productpage` (your URL will vary http://$GATEWAY_URL/productpage).


Let's look at this new deployment config with `kiali`. Before we do that, let's run some more traffic through this config.


Open up a new terminal and do the following:



#### Run some traffic through the new set up
```sh

## Load gateway config env vars
$ source util/set_up_gateway.sh                            

### Output
INGRESS_PORT=30851
SECURE_INGRESS_PORT=31073
INGRESS_HOST=192.168.64.18
GATEWAY is 192.168.64.18:30851
http://192.168.64.18:30851/productpage

## Curl the page and see that it is working as expected
$ curl -s http://$GATEWAY_URL/productpage | grep "<title>"

### Output
    <title>Simple Bookstore App</title>


## Run some load through the set up.
$ for i in `seq 1 10000`; do curl -s -o /dev/null http://$GATEWAY_URL/productpage; done
```


In a new terminal use `istioctl dashboard kiali` to launch kiali.

#### use `istioctl dashboard kiali` to launch kiali dashboard

```sh

$ istioctl dashboard kiali

### Output
http://localhost:64338/kiali
```


In the Kiali web UI do the following:

1. Click on `Graph` Navigation on the left side bar.
2. Select the `bookinfo` namespace from the namespace dropdown on the top left side of the main window


#### Kiali view of routing to only version 1

![Kiali Dashboard showing version 1 only routing](https://user-images.githubusercontent.com/382678/76174772-838f8180-6166-11ea-81a2-c96b6dcfc508.png)

You may wonder why `ratings` `v1` and `reviews` v2, and v3 are still visible. It is because they are still deployed.
There just is no routes that are routing traffic to them defined. If there was traffic, then you would see lines drawn to those in

#### BookInfo Kubernetes Deployments in istio bookinfo demo
![BookInfo Kubernetes Deployments in istio bookinfo demo](https://user-images.githubusercontent.com/382678/76174808-b2a5f300-6166-11ea-9f04-198d15f61eb1.png)

#### BookInfo Services defined in istio bookinfo demo
![BookInfo Services defined in istio bookinfo demo](https://user-images.githubusercontent.com/382678/76174936-6f984f80-6167-11ea-8d41-6d7bc3c4e650.png)



## Resources  
* [Istio the hard way, part 1](https://github.com/cloudurable/istio-the-hardway)
* [Istio the hard way, part 2, working with routes](https://github.com/cloudurable/istio-the-hardway/blob/master/route.md)
* [Set up Minikube on a Mac](http://cloudurable.com/blog/kubernetes_k8s_osx_setup_brew/index.html)
* [Kubectl cheatsheet](http://cloudurable.com/blog/kubernetes_k8s_kubectl_cheat_sheet/index.html)
* [Get started with Istio](https://istio.io/docs/setup/getting-started/)
* [Set up Istio command line](https://istio.io/docs/setup/install/istioctl/)
* [Set up Istio on minikube](https://istio.io/docs/setup/platform-setup/minikube/)
* [Install sample app](https://istio.io/docs/examples/bookinfo/)
* [Overview of tracing](https://istio.io/docs/tasks/observability/distributed-tracing/overview/)
* [Set up Jaeger](https://istio.io/docs/tasks/observability/distributed-tracing/jaeger/)
* [Master metrics set up](https://istio.io/docs/tasks/observability/metrics/)
* [Use Grafana](https://istio.io/docs/tasks/observability/metrics/using-istio-dashboard/)
* [Set up Kiali](https://istio.io/docs/tasks/observability/kiali/)
* [View example in Kiali](https://istio.io/docs/tasks/observability/kiali/)
* [Stuff you might want to demo in Kiali](https://kiali.io/documentation/features/)
* [Set up Logging](https://istio.io/docs/tasks/observability/logs/)
* [Set up FluentD and EFK](https://istio.io/docs/tasks/observability/mixer/logs/fluentd/#example-fluentd-elasticsearch-kibana-stack)
* [Description of different istio profiles](https://istio.io/docs/setup/additional-setup/config-profiles/)
* [Kubernetes CNI driver for Istio if you can't use init containers and side cars](https://istio.io/docs/setup/additional-setup/cni/)
* [Using `istioctl kube-inject` instead of auto injection](https://istio.io/docs/setup/additional-setup/sidecar-injection/)
# [Traffic Management](https://istio.io/docs/concepts/traffic-management/)
