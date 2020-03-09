# Canary deploys with Istio

Istio has support for A/B testing, canary deploys, etc.
It is common to migrate traffic gradually from microservice version to another one.
Istio allows you to configure rules that route a ratio traffic between different microservices.
To demonstrate [shifting traffic with Istio](https://istio.io/docs/tasks/traffic-management/traffic-shifting/), let's shift 50% of traffic to `reviews` `v1` and 50% to `reviews` `v3`. And, then shift to `reviews` `v3`.


## Review


To get the most out of this please install Istio and go through the basic routing guides.

* [Part 1: Install Istio and set up Istio sample BookInfo application](https://github.com/cloudurable/istio-the-hardway/blob/master/install.md)
* [Part 2: Istio the hard way round 2 - working with Istio Routes - VirtualServices](https://github.com/cloudurable/istio-the-hardway/blob/master/route.md)


## Make sure your environment is ready

Ensure that [minikube is running](https://github.com/cloudurable/istio-the-hardway/blob/master/route.md#make-sure-minikube-is-running-we-are-in-the-right-context-and-the-right-namespace), [the bookinfo services are installed](https://github.com/cloudurable/istio-the-hardway/blob/master/route.md#make-sure-our-services-are-running), and [the minikube tunnel is running](https://github.com/cloudurable/istio-the-hardway/blob/master/route.md#start-the-minikube-tunnel-cleanly).  To figure out the URL of your service [source set_up_gateway.sh](https://github.com/cloudurable/istio-the-hardway/blob/master/route.md#source-set_up_gatewaysh) (to see http://$GATEWAY_URL/productpage).



Let's see which VirtualServices that we have installed already

```sh
kubectl get virtualservices    


### Output                                            
NAME                GATEWAYS             HOSTS           AGE
bookinfo            [bookinfo-gateway]   [*]             4d2h
details                                  [details]       5h39m
productpage                              [productpage]   5h39m
ratings                                  [ratings]       5h39m
reviews-logged-in                        [reviews]       4h24m
```

If you see `reviews-logged-in` go ahead and delete it


```sh
$ kubectl delete  virtualservice reviews-logged-in

### Output
virtualservice.networking.istio.io "reviews-logged-in" deleted
```


Reset the services to route all traffic to v1 of each service.

```sh
kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml
```

Load the application a few times and see that `reviews` `v1` with no stars keeps showing up.


Now let's split the traffic between `reviews` `v1` and `reviews` `v3`.

```sh

$ kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml

### Output
virtualservice.networking.istio.io/reviews configured

```  

#### samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml

```yaml
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
      weight: 50
    - destination:
        host: reviews
        subset: v3
      weight: 50

```

Above you can see that there are two subsets and each subset is getting 50 percent of the load.


Load the application a few times and see that `reviews` `v1` with no stars shows up half the time and  `reviews` `v3` with red stars shows up half the time.

Now create a file called `canary.yaml` which is simlar to `virtual-service-reviews-50-v3.yaml`.

Set up `canary.yaml` manifest file so that `v1`, `v2`, and `v3` each get a weight of 50.


#### canary.yaml

```yaml
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
      weight: 50
    - destination:
        host: reviews
        subset: v2
      weight: 50
    - destination:
        host: reviews
        subset: v3
      weight: 50
```      


```sh
$ kubectl delete -f samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml

$ kubectl apply -f canary.yaml

### Output
Error from server: error when creating "canary.yaml": admission webhook "pilot.validation.istio.io" denied the request: configuration is invalid: total destination weight 150 != 100

```


Ok so that did not work. Let's modify `canary.yaml` so each version has 33.33 percent.


#### canary.yaml

```yaml
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
      weight: 33.33
    - destination:
        host: reviews
        subset: v2
      weight: 33.33
    - destination:
        host: reviews
        subset: v3
      weight: 33.33
```      

Now we should get the error message `spec.http.route.weight in body must be of type int32: "float64"`.

Let's try 34, 33 and 33 for the versions.

#### canary.yaml

```yaml
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
      weight: 34
    - destination:
        host: reviews
        subset: v2
      weight: 33
    - destination:
        host: reviews
        subset: v3
      weight: 33
```    

```sh
$ kubectl apply -f canary.yaml
virtualservice.networking.istio.io/reviews created
```

Load the application a few times and see that `reviews` `v1` with no stars shows up 1/3rd of the time,  `reviews` `v3` with red stars shows up 1/3rd of the time, and  `reviews` `v2` with black stars shows up 1/3rd of the time.

Now let's run some traffic through it.


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
$ for i in `seq 1 10000`; do curl -s -o /dev/null http://$GATEWAY_URL/productpage; sleep 1; done
```

## View Canary example in Kiali
Now let's see what this looks like in the kiali dashboard.

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
3. Turn Request percentages and traffic animation (in display dropdown).

#### Kiali showing percentages per service and traffic animation for Istio Bookinfo sample application
![Kiali showing percentages per service and traffic animation for Istio Bookinfo sample application](https://user-images.githubusercontent.com/382678/76189298-8d7da880-6197-11ea-8b52-04833a2c1761.png)


![Kiali](https://user-images.githubusercontent.com/382678/76190518-6aa0c380-619a-11ea-9c9a-08c6b6c6a592.png)

![Kiali](https://user-images.githubusercontent.com/382678/76190646-b3f11300-619a-11ea-8e7d-50cd3e6e5508.png)


## View Canary example in Kibana with EFK

Recall that we set up [fluentD and logging](https://github.com/cloudurable/istio-the-hardway/blob/master/install.md#logging).

In a separate terminal, set up the port for Kibana.

```sh
$ util/openKibanaPort.sh
Forwarding from 127.0.0.1:5601 -> 5601
Forwarding from [::1]:5601 -> 5601
```

Now open up http://localhost:5601/ and set up the Kibana fields until you get this:

(Hint: http://localhost:5601/app/kibana#/discover?_g=()&_a=(columns:!(destination,responseCode,source,severity,latency,user),index:ca96f3f0-601d-11ea-9f49-db2b751b3363,interval:m,query:(language:lucene,query:''),sort:!('@timestamp',desc))).


#### Viewing requests in Kibana
![Viewing requests in Kibana](https://user-images.githubusercontent.com/382678/76189725-a5a1f780-6198-11ea-8f36-01136726400d.png)

## View Canary example in Grafana

```sh
$ util/openGrafanaPort.sh
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
```

![Grafana](https://user-images.githubusercontent.com/382678/76190096-73dd6080-6199-11ea-91e4-4d764fdb520c.png)
