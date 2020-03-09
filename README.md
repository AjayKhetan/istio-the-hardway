## Istio the hard-way

We install the following Istio components and try some Itsio tasks.

* Grafana
* Prometheus
* Kiali
* FluentD, Elastic Search, and Kibana (EFK)
* Jaeger

The Istio getting started docs are not sequential per se. I tried to document an end-to-end, sit behind a keyboard and try things out guide to Istio. I also have tried to understand and dig a bit.

We also set up the BookInfo demo application using the getting started guide.


The ***BookInfo Istio Demo application*** has the following microservices:

* Productpage Microservice
* Details Microservice
* Reviews Microservice
* Ratings Microservice


#### BookInfo Services

![image](https://user-images.githubusercontent.com/382678/76173604-08c26880-615e-11ea-86b5-47fa0a1cf6ec.png)



There are two parts to this so far:

* [Part 1: Install Istio and set up Istio sample BookInfo application](https://github.com/cloudurable/istio-the-hardway/blob/master/install.md)
* [Part 2: Istio the hard way round 2 - working with Istio Routes - VirtualServices](https://github.com/cloudurable/istio-the-hardway/blob/master/route.md)


After you run through part 1, you should have Istio running on your local machine with minikube. 

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
* [Traffic Management](https://istio.io/docs/concepts/traffic-management/)
