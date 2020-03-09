# Istio the hard way round 2 - working with Istio Routes

## Using the route demo

Starting from where we left off in [the install guide aka Istio the Hard way](https://www.linkedin.com/pulse/istio-hard-way-rick-hightower/). You may recall that we installed the sample Istio `bookinfo` application which consists of several microservices.

Let's walk through the [route demo](https://istio.io/docs/tasks/traffic-management/request-routing/).

Let's review and make sure we are ready for part 2.

Recall we installed the sample Istio BookInfo application.

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

If you followed along with the first guide then you will have three versions of the `Ratings`microservice.


> To illustrate the problem this causes, access the Bookinfo app’s /productpage in a browser and refresh several times. You’ll notice that sometimes the book review output contains star ratings and other times it does not. This is because without an explicit default service version to route to, Istio routes requests to all available versions in a round robin fashion. --[route demo](https://istio.io/docs/tasks/traffic-management/request-routing/)


First let's route all of the traffic to just v1 of the reviews microservices.
But before we do that. Let's peek around a bit, and make sure all is well.


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

You may wonder why `ratings` `v1` and `reviews` v2, and v3 are still visible and yet no lines are drawn to them. It is because they are still deployed.
There just is no routes that are routing traffic to them defined. If there was traffic, then you would see lines drawn to those versions of services.

#### BookInfo Kubernetes Deployments in istio bookinfo demo
![BookInfo Kubernetes Deployments in istio bookinfo demo](https://user-images.githubusercontent.com/382678/76174808-b2a5f300-6166-11ea-9f04-198d15f61eb1.png)

#### BookInfo Services defined in istio bookinfo demo
![BookInfo Services defined in istio bookinfo demo](https://user-images.githubusercontent.com/382678/76174936-6f984f80-6167-11ea-8d41-6d7bc3c4e650.png)

## Route based on user identity

Next, let's change the route manifest files to route traffic based on a user named Jason.
The Jason user gets routed to the service `reviews` `v2`.


> Note that Istio doesn’t have any special, built-in understanding of user identity. This example is enabled by the fact that the productpage service adds a custom end-user header to all outbound HTTP requests to the reviews service. --[Route based on user identity](https://istio.io/docs/tasks/traffic-management/request-routing/#route-based-on-user-identity)


Run the following command to enable user-based routing:

#### samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml - apply user Jason routing

```sh  
$ kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml

### Output
virtualservice.networking.istio.io/reviews configured
```

#### samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml
```yaml

apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
    - reviews
  http:
  - match:
    - headers:
        end-user:
          exact: jason
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v1


```

See the config `spec->http->match->headers->end-user->exact:jason`.


Now, go to `http://$GATEWAY_URL/productpage` in your browser, and log in as user jason.

Logout or Log in as another user (e.g., Rick, Sue, etc.).
The traffic is routed to `reviews` `v1` for all users except Jason.
Note the differences in logging in as any user or a user named Jason.

#### Istio Route logging in as Joe instead of Jason
![Istio Route log in as Joe instead of Jason](https://user-images.githubusercontent.com/382678/76175761-45e12780-616b-11ea-82d1-ef1488cf0654.png)

#### Istio Route logging in as Jason
![Istio Route log in as Jason](https://user-images.githubusercontent.com/382678/76175808-7fb22e00-616b-11ea-9b36-653b3afebfff.png)


Log into as Jason and refresh the page a few times. Now load up the services graph in Kiali again. Notice that the Jason route use
 `reviews` `v2` microservice and the `reviews` `v` microservice uses the `ratings` `v1` service.

#### Jason Route uses reviews v2 which uses ratings v1
![Jason Route uses reviews v2 which uses ratings v1](https://user-images.githubusercontent.com/382678/76175855-b6884400-616b-11ea-9278-ffdcf5ae8a3d.png)



See [VirtualService route rules](https://istio.io/docs/reference/config/networking/virtual-service/#HTTPMatchRequest) because you can match URI, headers, request params, cookies, ports, gateway origins and a lot more than just headers.

The match values can be matched in several modes not just exact.
* exact: value for exact  match
* prefix: prefix match
* regex: regex-based match (e.g., non empty string `^(?!\s*$).+`)


## Checking to see if a user is logged in

Let's cement that last concept and augment the last example a bit.
Let's create a route that if a user is logged in at all routes `reviews` `v3`.
If they are a gold user, their user name is prefixed with `gold_` they get routed to `reviews` `v2`.
Then if they are not logged in at all they get routed to `reviews` `v1`.

* Logged in go to `reviews` `v3`
* Logged in as gold user to `reviews` `v2`
* Not logged in go to `reviews` `v1`.


Create a new route manifest file called `route_loggedin.yaml`.

#### Create a new route manifest file called route_loggedin.yaml
```sh

$ touch route_loggedin.yaml
$ atom route_loggedin.yaml

```

The `route_loggedin.yaml` will contain a prefix match and a regex match for header end-user as follows.

#### route_loggedin.yaml

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews-logged-in
spec:
  hosts:
    - reviews
  http:
  - match:
    - headers:
        end-user:
          regex: ^(?!\s*$).+
    route:
    - destination:
        host: reviews
        subset: v3
  - match:
    - headers:
        end-user:
          prefix: gold_
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v1

```

Recall last time we used only an exact match.
Now let's apply our new route manifest.


#### apply our new Istio VirtualService route manifest
```sh

## Delete the old rule so we don't have conflicts.
$ kubectl delete -f samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml

### Output
virtualservice.networking.istio.io "reviews" deleted


## Apply the new rules.
$ kubectl apply -f route_loggedin.yaml        

### Output                           
virtualservice.networking.istio.io/reviews-logged-in created

## Now let's see it.
$ kubectl get virtualservice reviews-logged-in -o yaml

### Output   
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"networking.istio.io/v1alpha3","kind":"VirtualService","metadata":{"annotations":{},"name":"reviews-logged-in","namespace":"bookinfo"},"spec":{"hosts":["reviews"],"http":[{"match":[{"headers":{"end-user":{"regex":"^(?!\\s*$).+"}}}],"route":[{"destination":{"host":"reviews","subset":"v3"}}]},{"match":[{"headers":{"end-user":{"prefix":"gold_"}}}],"route":[{"destination":{"host":"reviews","subset":"v2"}}]},{"route":[{"destination":{"host":"reviews","subset":"v1"}}]}]}}
  creationTimestamp: "2020-03-09T01:58:39Z"
  generation: 1
  name: reviews-logged-in
  namespace: bookinfo
  resourceVersion: "97713"
  selfLink: /apis/networking.istio.io/v1alpha3/namespaces/bookinfo/virtualservices/reviews-logged-in
  uid: c8194fc6-520d-47eb-be9b-1ce0681d45e7
spec:
  hosts:
  - reviews
  http:
  - match:
    - headers:
        end-user:
          regex: ^(?!\s*$).+
    route:
    - destination:
        host: reviews
        subset: v3
  - match:
    - headers:
        end-user:
          prefix: gold_
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v1
```

Now try logging in as a gold user, a logged in user and then try not logging in.



#### Istio route rules: Not logged in
![Istio route rules: Not logged in](https://user-images.githubusercontent.com/382678/76176761-2cda7580-616f-11ea-8923-6117d054e581.png)


#### Istio route rules: Logged in as a gold user
![Istio route rules: Logged in as a gold user](https://user-images.githubusercontent.com/382678/76176816-52677f00-616f-11ea-9c36-35c702b54e20.png)

#### Istio route rules: Any logged in user
![Istio route rules: Any logged in user](https://user-images.githubusercontent.com/382678/76176845-6dd28a00-616f-11ea-8f14-54a60dee6d03.png)

Try using the productpage web app with all three different ways then load up the Kiali Dashboard, and look at the services graph.
Turn on request percentages (2nd row of drop downs and the 2nd column).

#### Istio route rules shown in Kiali with request percentages
![Istio route rules shown in Kiali with request percentages](https://user-images.githubusercontent.com/382678/76177935-dbcc8080-6172-11ea-906c-2ed63616ffd0.png)

## Conclusion

In this task, we used Istio to send all traffic to the `v1` versions of each microservice in the Istio BookInfo sample.
Then you routed traffic differently if the user was logged in as `Jason` using an `exact` match. Then we just did a rift and
wrote some route rules that matched if a user was logged, if they were not logged in and if they were a gold user using `prefix`, and `regex` matches.



## Resources  
* [Istio the hard way, part 1](https://github.com/cloudurable/istio-the-hardway)
* [Istio the hard way, part 2, working with routes](https://github.com/cloudurable/istio-the-hardway/blob/master/route.md)
* [VirtualService route rules](https://istio.io/docs/reference/config/networking/virtual-service/#HTTPMatchRequest)
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
* [Traffic Management](https://istio.io/docs/concepts/traffic-management/)
