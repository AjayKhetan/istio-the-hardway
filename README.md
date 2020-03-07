## Istio the hard-way ROUGH EARLY DRAFT

I went through the Istio install a few times and it didn't always work or I did things, broke some thing and then had to manually fix.
The instructions are all there but I found them sort of scattered about.
I was looking for the easiest way to get the demos running and then try them out as I am scripting some demos and trying some out for  projects and talks.
I thought I would start by writing them all down in one place.

You can find [this here and add issues and ask questions](https://github.com/cloudurable/istio-the-hardway). 


> NOTE: This is a super super rough draft. It works. I've been through a few times. I more than likely to script out some demos on top of this base rather than spend a lot of time improving this per se. At least no major improvements in the next few weeks. You will see some TODOs.

All of this was around [Getting started with Istio docs](https://istio.io/docs/setup/getting-started/) which is sort of a build your own story format. I tried to put a single path where you can install:

* Grafana
* Prometheus
* Kiali
* FluentD, Elastic Search, and Kibana
* Jaeger


Then start talking about this tools and writing guides and tutorials on top of this base install.

![image](https://user-images.githubusercontent.com/382678/76135990-71380b00-5fe1-11ea-9406-5d48941c603b.png)


## Istio Setup

I have a 32 GB RAM Mac book pro so I am just going to run everything on my laptop on MiniKube.
Later I might try it out on OpenShift CRC or KIND or GKE.
For now, I am going to use [Minikube on my Mac](http://cloudurable.com/blog/kubernetes_k8s_osx_setup_brew/index.html), [kubectl, kubectx, etc.](http://cloudurable.com/blog/kubernetes_k8s_kubectl_cheat_sheet/index.html).


#### Setting up Minikube

Let's start by [setting up MiniKube](https://istio.io/docs/setup/platform-setup/minikube/).

```sh

brew install minikube


minikube start  --kubernetes-version=v1.15.10 \
                --vm-driver=hyperkit \
                --cpus=7 \
                --disk-size='100000mb' \
                --memory='9000mb'

### Output        
😄  minikube v1.7.3 on Darwin 10.15.1
✨  Using the hyperkit driver based on user configuration
💾  Downloading driver docker-machine-driver-hyperkit:
    > docker-machine-driver-hyperkit.sha256: 65 B / 65 B [---] 100.00% ? p/s 0s
    > docker-machine-driver-hyperkit: 10.88 MiB / 10.88 MiB  100.00% 11.03 MiB
🔑  The 'hyperkit' driver requires elevated permissions. The following commands will be executed:

    $ sudo chown root:wheel /Users/richardhightower/.minikube/bin/docker-machine-driver-hyperkit
    $ sudo chmod u+s /Users/richardhightower/.minikube/bin/docker-machine-driver-hyperkit


Password:
💿  Downloading VM boot image ...
    > minikube-v1.7.3.iso.sha256: 65 B / 65 B [--------------] 100.00% ? p/s 0s
    > minikube-v1.7.3.iso: 167.39 MiB / 167.39 MiB [-] 100.00% 42.51 MiB p/s 4s
🔥  Creating hyperkit VM (CPUs=7, Memory=9000MB, Disk=100000MB) ...
🐳  Preparing Kubernetes v1.15.10 on Docker 19.03.6 ...
💾  Downloading kubeadm v1.15.10
💾  Downloading kubelet v1.15.10
💾  Downloading kubectl v1.15.10
🚀  Launching Kubernetes ...
🌟  Enabling addons: default-storageclass, storage-provisioner
⌛  Waiting for cluster to come online ...
🏄  Done! kubectl is now configured to use "minikube"

```

Last release of Istio has not been tested with Kubernetes 1.16.x so we lock
down Minikube to `v1.15.10` via `kubernetes-version`.
Most of the instructions should work even if you
do not use MiniKube but for the sake of having it all in one place, let's stick
to MiniKube. If you are using a Mac or new to Kubectl check out these resources:
setting up [MiniKube on OSX](http://cloudurable.com/blog/kubernetes_k8s_osx_setup_brew/index.html)
and [kubectl cheatsheet](http://cloudurable.com/blog/kubernetes_k8s_kubectl_cheat_sheet/index.html).


In my home directory, I created a directory called `istio` and follow the instructions
in [Istio: Getting Started](https://istio.io/docs/setup/getting-started/).

#### Installing Istio Command line Tools
```sh

curl -L https://istio.io/downloadIstio | sh -  
pwd
/Users/richardhightower/istio/istio-1.4.5
```

I added this to my `~/.zshrc` (use `~/.bashrc` if you use bash).
This puts the `istioctl` on the command line and adds [auto shell completion](https://istio.io/docs/ops/diagnostic-tools/istioctl#enabling-auto-completion).  

#### Add code completion and auto completion
```sh
export PATH="~/istio/istio-1.4.5/bin:$PATH"
source  ~/istio/istio-1.4.5/tools/_istioctl
```


## Install istio into your cluster with istioctl

Now we will install istio into your cluster with `istioctl` command line tool.

Next we want to install istio with all of the bells and whistles: logging, Kiali, EFK, etc. so we will use the [demo profile](https://istio.io/docs/setup/install/istioctl/).

Let's [set up some secrets for Kiali](https://istio.io/docs/tasks/observability/kiali/) so the service mesh can be visualized from the start.

#### zsh user name / password entry
```sh
$ KIALI_USERNAME=$(read '?Kiali Username: ' uval && echo -n $uval | base64)
$ KIALI_PASSPHRASE=$(read -s "?Kiali Passphrase: " pval && echo -n $pval | base64)
```

#### bash user name / password entry

```sh
KIALI_USERNAME=$(read -p 'Kiali Username: ' uval && echo -n $uval | base64)
KIALI_PASSPHRASE=$(read -sp 'Kiali Passphrase: ' pval && echo -n $pval | base64)

```

Note to keep it simple use something you can remember. Maybe not admin/admin.

Now that we have the kiali secret set up.

Let's install all the istio bells and whistles with `istioctl`

```sh
istioctl manifest apply --set profile=demo --set values.kiali.enabled=true

### Output
- Applying manifest for component Base...
✔ Finished applying manifest for component Base.
- Applying manifest for component Tracing...
- Applying manifest for component Citadel...
- Applying manifest for component Galley...
- Applying manifest for component Kiali...
- Applying manifest for component IngressGateway...
- Applying manifest for component Pilot...
- Applying manifest for component Prometheus...
- Applying manifest for component Policy...
- Applying manifest for component EgressGateway...
- Applying manifest for component Injector...
- Applying manifest for component Telemetry...
- Applying manifest for component Grafana...
✔ Finished applying manifest for component Citadel.
✔ Finished applying manifest for component Prometheus.
✔ Finished applying manifest for component Tracing.
✔ Finished applying manifest for component Kiali.
✔ Finished applying manifest for component Galley.
✔ Finished applying manifest for component Injector.
✔ Finished applying manifest for component IngressGateway.
✔ Finished applying manifest for component EgressGateway.
✔ Finished applying manifest for component Pilot.
✔ Finished applying manifest for component Policy.
✔ Finished applying manifest for component Telemetry.
✔ Finished applying manifest for component Grafana.


✔ Installation complete
```

## Let's ensure istio is installed


```sh
kubectl get namespaces


### Output
NAME              STATUS   AGE
default           Active   6m41s
istio-system      Active   71s     <------ THERE IT IS
kube-node-lease   Active   6m42s
kube-public       Active   6m42s
kube-system       Active   6m42s
```
We can see the namespace istio-system.

Let's look around a bit.

Let's switch the namespace with [kubens](https://github.com/ahmetb/kubectx).

#### Switch namespace with kubens
```sh
kubens istio-system
Context "minikube" modified.
Active namespace is "istio-system".
```

Let's look at the workloads running in the `istio-system` namespace.


#### List the pods running in `istio-system`

```sh
kubectl get pods

### Output
NAME                                      READY   STATUS    RESTARTS   AGE
grafana-6c8f45499-b7pgl                   1/1     Running   0          3m54s
istio-citadel-767757649c-wk5z6            1/1     Running   0          3m56s
istio-egressgateway-5585c98cdb-mjhsj      1/1     Running   0          3m56s
istio-galley-6d467f5567-v6w7p             1/1     Running   0          3m55s
istio-ingressgateway-77d7cc794-7jf2p      1/1     Running   0          3m56s
istio-pilot-58584cfd66-mdt4n              1/1     Running   0          3m55s
istio-policy-5dc7977678-94vgf             1/1     Running   1          3m55s
istio-sidecar-injector-68d9b4bb87-kt28b   1/1     Running   0          3m55s
istio-telemetry-5b8f48df4b-f4drw          1/1     Running   2          3m56s
istio-tracing-78548677bc-8m2t2            1/1     Running   0          3m56s
kiali-fb5f485fb-96gjw                     1/1     Running   0          3m55s
prometheus-685585888b-k45tr               1/1     Running   0          3m56s
```

Next we will want to verify the install with istioctl.


#### verify install with istioctl

```sh

## Generate manifest from demo profile
$ istioctl manifest  generate --context=demo > generated-manifest.yaml

## Verify manifest against running cluster
$ istioctl verify-install -f generated-manifest.yaml

ClusterRole: istio-reader-istio-system.default checked successfully
ClusterRoleBinding: istio-reader-istio-system.default checked successfully
CustomResourceDefinition: attributemanifests.config.istio.io.default checked successfully
CustomResourceDefinition: clusterrbacconfigs.rbac.istio.io.default checked successfully
CustomResourceDefinition: destinationrules.networking.istio.io.default checked successfully
CustomResourceDefinition: envoyfilters.networking.istio.io.default checked successfully
CustomResourceDefinition: gateways.networking.istio.io.default checked successfully
CustomResourceDefinition: httpapispecbindings.config.istio.io.default checked successfully
CustomResourceDefinition: httpapispecs.config.istio.io.default checked successfully
CustomResourceDefinition: meshpolicies.authentication.istio.io.default checked successfully
CustomResourceDefinition: policies.authentication.istio.io.default checked successfully
CustomResourceDefinition: quotaspecbindings.config.istio.io.default checked successfully
CustomResourceDefinition: quotaspecs.config.istio.io.default checked successfully
CustomResourceDefinition: rbacconfigs.rbac.istio.io.default checked successfully
CustomResourceDefinition: rules.config.istio.io.default checked successfully
CustomResourceDefinition: serviceentries.networking.istio.io.default checked successfully
CustomResourceDefinition: servicerolebindings.rbac.istio.io.default checked successfully
CustomResourceDefinition: serviceroles.rbac.istio.io.default checked successfully
CustomResourceDefinition: virtualservices.networking.istio.io.default checked successfully
CustomResourceDefinition: adapters.config.istio.io.default checked successfully
CustomResourceDefinition: instances.config.istio.io.default checked successfully
CustomResourceDefinition: templates.config.istio.io.default checked successfully
CustomResourceDefinition: handlers.config.istio.io.default checked successfully
CustomResourceDefinition: sidecars.networking.istio.io.default checked successfully
CustomResourceDefinition: authorizationpolicies.security.istio.io.default checked successfully
Namespace: istio-system.default checked successfully
ServiceAccount: istio-reader-service-account.istio-system checked successfully
ClusterRole: istio-citadel-istio-system.default checked successfully
ClusterRoleBinding: istio-citadel-istio-system.default checked successfully
Deployment: istio-citadel.istio-system checked successfully
PodDisruptionBudget: istio-citadel.istio-system checked successfully
Service: istio-citadel.istio-system checked successfully
ServiceAccount: istio-citadel-service-account.istio-system checked successfully
ClusterRole: istio-galley-istio-system.default checked successfully
ClusterRoleBinding: istio-galley-admin-role-binding-istio-system.default checked successfully
...

Service: istio-telemetry.istio-system checked successfully
ServiceAccount: istio-mixer-service-account.istio-system checked successfully
Checked 23 crds
Checked 7 Istio Deployments
Istio is installed successfully

rm generated-manifest.yaml
```

It appears that it mostly worked. We may have to set up a `galled-envoy-config`.

The `generate` command generates the manifest for the demo profile then
`verify-install` verifies the manifest against what is running in the cluster.


Let's look around a bit more.

## Looking around istio system
```sh
$ kubectl get configmaps

### Output
NAME                                                                 DATA   AGE
injector-mesh                                                        1      13m
istio                                                                3      13m
istio-galley-configuration                                           1      13m
istio-grafana                                                        2      13m
istio-grafana-configuration-dashboards-citadel-dashboard             1      13m
istio-grafana-configuration-dashboards-galley-dashboard              1      13m
istio-grafana-configuration-dashboards-istio-mesh-dashboard          1      13m
istio-grafana-configuration-dashboards-istio-performance-dashboard   1      13m
istio-grafana-configuration-dashboards-istio-service-dashboard       1      13m
istio-grafana-configuration-dashboards-istio-workload-dashboard      1      13m
istio-grafana-configuration-dashboards-mixer-dashboard               1      13m
istio-grafana-configuration-dashboards-pilot-dashboard               1      13m
istio-mesh-galley                                                    1      13m
istio-security                                                       1      13m
istio-sidecar-injector                                               2      13m
kiali                                                                1      13m
pilot-envoy-config                                                   1      13m
policy-envoy-config                                                  1      13m
prometheus                                                           1      13m
telemetry-envoy-config                                               1      13m


$ kubectl get deployments


### Output
NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
grafana                  1/1     1            1           15m
istio-citadel            1/1     1            1           15m
istio-egressgateway      1/1     1            1           15m
istio-galley             1/1     1            1           15m
istio-ingressgateway     1/1     1            1           15m
istio-pilot              1/1     1            1           15m
istio-policy             1/1     1            1           15m
istio-sidecar-injector   1/1     1            1           15m
istio-telemetry          1/1     1            1           15m
istio-tracing            1/1     1            1           15m
kiali                    1/1     1            1           15m
prometheus               1/1     1            1           15m



$ kubectl get svc        
NAME                     TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                                                                                      AGE
grafana                  ClusterIP      10.109.55.124    <none>        3000/TCP                                                                                                                     15m
istio-citadel            ClusterIP      10.99.73.238     <none>        8060/TCP,15014/TCP                                                                                                           16m
istio-egressgateway      ClusterIP      10.106.10.25     <none>        80/TCP,443/TCP,15443/TCP                                                                                                     15m
istio-galley             ClusterIP      10.103.230.190   <none>        443/TCP,15014/TCP,9901/TCP,15019/TCP                                                                                         15m
istio-ingressgateway     LoadBalancer   10.107.13.254    <pending>     15020:31018/TCP,80:30851/TCP,443:31073/TCP,15029:31105/TCP,15030:30824/TCP,15031:31640/TCP,15032:30206/TCP,15443:30523/TCP   15m
istio-pilot              ClusterIP      10.106.208.222   <none>        15010/TCP,15011/TCP,8080/TCP,15014/TCP                                                                                       15m
istio-policy             ClusterIP      10.110.64.14     <none>        9091/TCP,15004/TCP,15014/TCP                                                                                                 15m
istio-sidecar-injector   ClusterIP      10.103.96.230    <none>        443/TCP                                                                                                                      15m
istio-telemetry          ClusterIP      10.99.155.191    <none>        9091/TCP,15004/TCP,15014/TCP,42422/TCP                                                                                       15m
jaeger-agent             ClusterIP      None             <none>        5775/UDP,6831/UDP,6832/UDP                                                                                                   16m
jaeger-collector         ClusterIP      10.96.91.234     <none>        14267/TCP,14268/TCP,14250/TCP                                                                                                16m
jaeger-query             ClusterIP      10.98.226.215    <none>        16686/TCP                                                                                                                    16m
kiali                    ClusterIP      10.104.29.238    <none>        20001/TCP                                                                                                                    16m
prometheus               ClusterIP      10.104.5.36      <none>        9090/TCP                                                                                                                     16m
tracing                  ClusterIP      10.106.130.227   <none>        80/TCP                                                                                                                       16m
zipkin                   ClusterIP      10.109.148.252   <none>        9411/TCP


$ kubectl get crd


### Output
NAME                                      CREATED AT
adapters.config.istio.io                  2020-03-05T02:40:25Z
attributemanifests.config.istio.io        2020-03-05T02:40:25Z
authorizationpolicies.security.istio.io   2020-03-05T02:40:25Z
clusterrbacconfigs.rbac.istio.io          2020-03-05T02:40:25Z
destinationrules.networking.istio.io      2020-03-05T02:40:25Z
envoyfilters.networking.istio.io          2020-03-05T02:40:25Z
gateways.networking.istio.io              2020-03-05T02:40:25Z
handlers.config.istio.io                  2020-03-05T02:40:25Z
httpapispecbindings.config.istio.io       2020-03-05T02:40:25Z
httpapispecs.config.istio.io              2020-03-05T02:40:25Z
instances.config.istio.io                 2020-03-05T02:40:25Z
meshpolicies.authentication.istio.io      2020-03-05T02:40:25Z
policies.authentication.istio.io          2020-03-05T02:40:25Z
quotaspecbindings.config.istio.io         2020-03-05T02:40:25Z
quotaspecs.config.istio.io                2020-03-05T02:40:25Z
rbacconfigs.rbac.istio.io                 2020-03-05T02:40:25Z
rules.config.istio.io                     2020-03-05T02:40:25Z
serviceentries.networking.istio.io        2020-03-05T02:40:25Z
servicerolebindings.rbac.istio.io         2020-03-05T02:40:25Z
serviceroles.rbac.istio.io                2020-03-05T02:40:25Z
sidecars.networking.istio.io              2020-03-05T02:40:25Z
templates.config.istio.io                 2020-03-05T02:40:25Z
virtualservices.networking.istio.io       2020-03-05T02:40:25Z

```

____





——


## Installing Istio Book Info example application

For this, let's create a namespace called `bookinfo`.
Use `kubens` to change to the `bookinfo` namespace, and then install the sample application.

#### bookinfo.json - Namespace manifest for bookinfo
```javascript
{
  "apiVersion": "v1",
  "kind": "Namespace",
  "metadata": {
    "name": "bookinfo",
    "labels": {
      "name": "bookinfo"
    }
  }
}
```

Create the bookinfo namespace with kubectl.

#### Create bookinfo namespace

```sh
$ kubectl apply -f bookinfo.json

### Output
namespace/bookinfo created
```


Change to the bookinfo namespace with kubens.

#### Change the current namespace to bookinfo with kubens

```sh

$ kubens bookinfo

### Output
Context "minikube" modified.
Active namespace is "bookinfo".

(⎈ |minikube:bookinfo)richardhightower@Richards-MacBook-Pro istio-1.4.5 %
 $

```

Next we install the sample microservices with `kubectl apply -f`.

#### Install the sample microservices for istio

```sh

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

### Output
service/details created
serviceaccount/bookinfo-details created
deployment.apps/details-v1 created
service/ratings created
serviceaccount/bookinfo-ratings created
deployment.apps/ratings-v1 created
service/reviews created
serviceaccount/bookinfo-reviews created
deployment.apps/reviews-v1 created
deployment.apps/reviews-v2 created
deployment.apps/reviews-v3 created
service/productpage created
serviceaccount/bookinfo-productpage created
deployment.apps/productpage-v1 created
```

#### samples/bookinfo/platform/kube/bookinfo.yaml --- Example Istio Microservices
```yaml

# Copyright 2017 Istio Authors
#
...

##################################################################################################
# This file defines the services, service accounts, and deployments for the Bookinfo sample.
#
# To apply all 4 Bookinfo services, their corresponding service accounts, and deployments:
#
#   kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
#
# Alternatively, you can deploy any resource separately:
#
#   kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml -l service=reviews # reviews Service
#   kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml -l account=reviews # reviews ServiceAccount
#   kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml -l app=reviews,version=v3 # reviews-v3 Deployment
##################################################################################################

##################################################################################################
# Details service
##################################################################################################
apiVersion: v1
kind: Service
metadata:
  name: details
  labels:
    app: details
    service: details
spec:
  ports:
  - port: 9080
    name: http
  selector:
    app: details
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: bookinfo-details
  labels:
    account: details
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: details-v1
  labels:
    app: details
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: details
      version: v1
  template:
    metadata:
      labels:
        app: details
        version: v1
    spec:
      serviceAccountName: bookinfo-details
      containers:
      - name: details
        image: docker.io/istio/examples-bookinfo-details-v1:1.15.0
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
---
##################################################################################################
# Ratings service
##################################################################################################
apiVersion: v1
kind: Service
metadata:
  name: ratings
  labels:
    app: ratings
    service: ratings
spec:
  ports:
  - port: 9080
    name: http
  selector:
    app: ratings
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: bookinfo-ratings
  labels:
    account: ratings
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ratings-v1
  labels:
    app: ratings
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ratings
      version: v1
  template:
    metadata:
      labels:
        app: ratings
        version: v1
    spec:
      serviceAccountName: bookinfo-ratings
      containers:
      - name: ratings
        image: docker.io/istio/examples-bookinfo-ratings-v1:1.15.0
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
---
##################################################################################################
# Reviews service
##################################################################################################
apiVersion: v1
kind: Service
metadata:
  name: reviews
  labels:
    app: reviews
    service: reviews
spec:
  ports:
  - port: 9080
    name: http
  selector:
    app: reviews
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: bookinfo-reviews
  labels:
    account: reviews
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: reviews-v1
  labels:
    app: reviews
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reviews
      version: v1
  template:
    metadata:
      labels:
        app: reviews
        version: v1
    spec:
      serviceAccountName: bookinfo-reviews
      containers:
      - name: reviews
        image: docker.io/istio/examples-bookinfo-reviews-v1:1.15.0
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: reviews-v2
  labels:
    app: reviews
    version: v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reviews
      version: v2
  template:
    metadata:
      labels:
        app: reviews
        version: v2
    spec:
      serviceAccountName: bookinfo-reviews
      containers:
      - name: reviews
        image: docker.io/istio/examples-bookinfo-reviews-v2:1.15.0
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: reviews-v3
  labels:
    app: reviews
    version: v3
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reviews
      version: v3
  template:
    metadata:
      labels:
        app: reviews
        version: v3
    spec:
      serviceAccountName: bookinfo-reviews
      containers:
      - name: reviews
        image: docker.io/istio/examples-bookinfo-reviews-v3:1.15.0
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
---
##################################################################################################
# Productpage services
##################################################################################################
apiVersion: v1
kind: Service
metadata:
  name: productpage
  labels:
    app: productpage
    service: productpage
spec:
  ports:
  - port: 9080
    name: http
  selector:
    app: productpage
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: bookinfo-productpage
  labels:
    account: productpage
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: productpage-v1
  labels:
    app: productpage
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: productpage
      version: v1
  template:
    metadata:
      labels:
        app: productpage
        version: v1
    spec:
      serviceAccountName: bookinfo-productpage
      containers:
      - name: productpage
        image: docker.io/istio/examples-bookinfo-productpage-v1:1.15.0
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
---


```

The above is what we just added to our `MiniKube` cluster in the `bookinfo` namespace.

#### Services that are in the bookinfo example

```sh
$ kubectl get services
NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
details       ClusterIP   10.97.156.181    <none>        9080/TCP   6m58s
productpage   ClusterIP   10.109.127.25    <none>        9080/TCP   6m58s
ratings       ClusterIP   10.103.85.216    <none>        9080/TCP   6m58s
reviews       ClusterIP   10.102.142.199   <none>        9080/TCP   6m58s
```



At this point, the istio proxy has not been injected and we can verify that
by using `kubectl describe pod` to look at containers in a the  `productpage` pod.


### Verify that there are no side car containers yet.
```sh
$ PRODUCT_POD="$(kubectl get pods | grep productpage | awk '{print $1}')"
$ kubectl describe pod $PRODUCT_POD  

Name:           productpage-v1-8554d58bff-s9l76
Namespace:      bookinfo
Priority:       0
Node:           minikube/192.168.64.18
Start Time:     Wed, 04 Mar 2020 19:09:19 -0800
Labels:         app=productpage
...
Controlled By:  ReplicaSet/productpage-v1-8554d58bff
Containers:
  productpage:
    ...
    Image ID:       docker-pullable://istio/examples-bookinfo-productpage-    
    Port:           9080/TCP
    Host Port:      0/TCP
    ...
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from bookinfo-productpage-token-vrnwb (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  bookinfo-productpage-token-vrnwb:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  bookinfo-productpage-token-vrnwb
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  3m28s  default-scheduler  Successfully assigned bookinfo/productpage-v1-8554d58bff-s9l76 to minikube
  Normal  Pulling    3m27s  kubelet, minikube  Pulling image "docker.io/istio/examples-bookinfo-productpage-v1:1.15.0"
  Normal  Pulled     2m52s  kubelet, minikube  Successfully pulled image "docker.io/istio/examples-bookinfo-productpage-v1:1.15.0"
  Normal  Created    2m52s  kubelet, minikube  Created container productpage
  Normal  Started    2m52s  kubelet, minikube  Started container productpage

```

Notice this pod only has one container and that is the productpage container.  

## Injecting the istio sidecars into the istio sample bookinfo app.

To get the istio side car injection to work, we will need to use
`kubectl label` to label the `bookinfo` with `istio-injection` enable.

#### Enabling side car injection for bookinfo namespace with kubectl label

```sh
kubectl label namespace bookinfo istio-injection=enabled

### Output
namespace/bookinfo labeled
```

First lets reload the bookinfo example


```sh

## Delete the objects in the manifest.
$ kubectl delete -f samples/bookinfo/platform/kube/bookinfo.yaml


### Output
service "details" deleted
serviceaccount "bookinfo-details" deleted
deployment.apps "details-v1" deleted
service "ratings" deleted
serviceaccount "bookinfo-ratings" deleted
deployment.apps "ratings-v1" deleted
service "reviews" deleted
serviceaccount "bookinfo-reviews" deleted
deployment.apps "reviews-v1" deleted
deployment.apps "reviews-v2" deleted
deployment.apps "reviews-v3" deleted
service "productpage" deleted
serviceaccount "bookinfo-productpage" deleted
deployment.apps "productpage-v1" deleted


## Apply the objects in the maifest
$ kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml


## Output
service/details created
serviceaccount/bookinfo-details created

```


Now we should see the additional containers in the pods.


At this point, the istio proxy has been injected and we can verify that
by using `kubectl describe pod` to look at containers in a the  `productpage` pod.
Notice the initContainers section as well.

#### Verify that there are side car containers and init containers

```sh
$ PRODUCT_POD="$(kubectl get pods | grep productpage | awk '{print $1}')"
$ kubectl describe pod $PRODUCT_POD
Name:           productpage-v1-8554d58bff-p8cwp
Namespace:      bookinfo
Priority:       0
Node:           minikube/192.168.64.18
Start Time:     Wed, 04 Mar 2020 19:23:04 -0800
Labels:         app=productpage
                pod-template-hash=8554d58bff
                security.istio.io/tlsMode=istio
                version=v1
Annotations:    sidecar.istio.io/status:...
Status:         Running
IP:             172.17.0.25
IPs:            <none>
Controlled By:  ReplicaSet/productpage-v1-8554d58bff
Init Containers:
  istio-init:
    Container ID:  docker://885f2fa1b3bcf7159d45b3decdf0e1bd0409e13389c3415b90e867567b352c9d
    Image:         docker.io/istio/proxyv2:1.4.5
    Image ID:      docker-pullable://istio/proxyv2@sha256:fc09ea0f969147a4843a564c5b677fbf3a6f94b56627d00b313b4c30d5fef094
    Port:          <none>
    Host Port:     <none>
    Command:
      istio-iptables
      -p
      15001
...
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Wed, 04 Mar 2020 19:23:05 -0800
      Finished:     Wed, 04 Mar 2020 19:23:05 -0800
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     100m
      memory:  50Mi
    Requests:
      cpu:        10m
      memory:     10Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from bookinfo-productpage-token-kggjt (ro)
Containers:
  productpage:
    ...
    Image:          docker.io/istio/examples-bookinfo-productpage-v1:1.15.0
    ...
    Port:           9080/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 04 Mar 2020 19:23:06 -0800
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from bookinfo-productpage-token-kggjt (ro)
  istio-proxy:
    ...
    Image:         docker.io/istio/proxyv2:1.4.5
    ...
    Port:          15090/TCP
    Host Port:     0/TCP
    Args:
      proxy
      sidecar
      --domain
      $(POD_NAMESPACE).svc.cluster.local
      --configPath
      /etc/istio/proxy
      --binaryPath
      /usr/local/bin/envoy
      --serviceCluster
      productpage.$(POD_NAMESPACE)
      ...
      15020
      --applicationPorts
      9080
      --trust-domain=cluster.local
    State:          Running
      Started:      Wed, 04 Mar 2020 19:23:06 -0800
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     2
      memory:  1Gi
    Requests:
      cpu:      10m
      memory:   40Mi
    Readiness:  http-get http://:15020/healthz/ready delay=1s timeout=1s period=2s #success=1 #failure=30
    Environment:
      POD_NAME:                          productpage-v1-8554d58bff-p8cwp (v1:metadata.name)
      POD_NAMESPACE:                     bookinfo (v1:metadata.namespace)
      INSTANCE_IP:                        (v1:status.podIP)
      SERVICE_ACCOUNT:                    (v1:spec.serviceAccountName)
      HOST_IP:                            (v1:status.hostIP)
      ...
      ISTIO_META_CLUSTER_ID:             Kubernetes
      ISTIO_META_POD_NAME:               productpage-v1-8554d58bff-p8cwp (v1:metadata.name)
      ISTIO_META_CONFIG_NAMESPACE:       bookinfo (v1:metadata.namespace)
      ...
      ISTIO_META_INTERCEPTION_MODE:      REDIRECT
      ISTIO_META_INCLUDE_INBOUND_PORTS:  9080
      ISTIO_METAJSON_LABELS:             {"app":"productpage","pod-template-hash":"8554d58bff","version":"v1"}

      ISTIO_META_WORKLOAD_NAME:          productpage-v1
      ISTIO_META_OWNER:                  kubernetes://apis/apps/v1/namespaces/bookinfo/deployments/productpage-v1
      ...
      ISTIO_META_MESH_ID:                cluster.local
    Mounts:
      /etc/certs/ from istio-certs (ro)
      /etc/istio/proxy from istio-envoy (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from bookinfo-productpage-token-kggjt (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
...
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  2m5s  default-scheduler  Successfully assigned bookinfo/productpage-v1-8554d58bff-p8cwp to minikube
  Normal  Pulled     2m4s  kubelet, minikube  Container image "docker.io/istio/proxyv2:1.4.5" already present on machine
  Normal  Created    2m4s  kubelet, minikube  Created container istio-init
  Normal  Started    2m4s  kubelet, minikube  Started container istio-init
  Normal  Pulled     2m4s  kubelet, minikube  Container image "docker.io/istio/examples-bookinfo-productpage-v1:1.15.0" already present on machine
  Normal  Created    2m3s  kubelet, minikube  Created container productpage
  Normal  Started    2m3s  kubelet, minikube  Started container productpage
  Normal  Pulled     2m3s  kubelet, minikube  Container image "docker.io/istio/proxyv2:1.4.5" already present on machine
  Normal  Created    2m3s  kubelet, minikube  Created container istio-proxy
  Normal  Started    2m3s  kubelet, minikube  Started container istio-proxy
```

Notice that we have more images in our pod. The istio proxy is there too (see `istio-proxy`).
You can see the additional containers and an init container (`istio-init`).


___


## Installed services in Istio demo

We used the demo install of Istio which installed Prometheus (metrics gatherer, alerts, etc. for KPIs),
Grafana (metrics viewer), Kiali (Service Mesh UI), Jaeger (OpenTrace implementation), and all of the Istio plumbing.


Let's Look around the istio-system namespace.

```sh
kubectl --namespace istio-system get pods
NAME                                      READY   STATUS    RESTARTS   AGE
grafana-6c8f45499-b7pgl                   1/1     Running   0          45h
istio-citadel-767757649c-wk5z6            1/1     Running   0          45h
istio-egressgateway-5585c98cdb-mjhsj      1/1     Running   0          45h
istio-galley-6d467f5567-v6w7p             1/1     Running   0          45h
istio-ingressgateway-77d7cc794-7jf2p      1/1     Running   0          45h
istio-pilot-58584cfd66-mdt4n              1/1     Running   0          45h
istio-policy-5dc7977678-94vgf             1/1     Running   1          45h
istio-sidecar-injector-68d9b4bb87-kt28b   1/1     Running   0          45h
istio-telemetry-5b8f48df4b-f4drw          1/1     Running   2          45h
istio-tracing-78548677bc-8m2t2            1/1     Running   0          45h
kiali-fb5f485fb-96gjw                     1/1     Running   0          45h
prometheus-685585888b-k45tr               1/1     Running   0          45h
```

## Installed services in Istio demo
```
kubectl -n istio-system get svc


### Output
NAME                     TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                                                                                      AGE
grafana                  ClusterIP      10.109.55.124    <none>        3000/TCP                                                                                                                     45h
istio-citadel            ClusterIP      10.99.73.238     <none>        8060/TCP,15014/TCP                                                                                                           45h
istio-egressgateway      ClusterIP      10.106.10.25     <none>        80/TCP,443/TCP,15443/TCP                                                                                                     45h
istio-galley             ClusterIP      10.103.230.190   <none>        443/TCP,15014/TCP,9901/TCP,15019/TCP                                                                                         45h
istio-ingressgateway     LoadBalancer   10.107.13.254    <pending>     15020:31018/TCP,80:30851/TCP,443:31073/TCP,15029:31105/TCP,15030:30824/TCP,15031:31640/TCP,15032:30206/TCP,15443:30523/TCP   45h
istio-pilot              ClusterIP      10.106.208.222   <none>        15010/TCP,15011/TCP,8080/TCP,15014/TCP                                                                                       45h
istio-policy             ClusterIP      10.110.64.14     <none>        9091/TCP,15004/TCP,15014/TCP                                                                                                 45h
istio-sidecar-injector   ClusterIP      10.103.96.230    <none>        443/TCP                                                                                                                      45h
istio-telemetry          ClusterIP      10.99.155.191    <none>        9091/TCP,15004/TCP,15014/TCP,42422/TCP                                                                                       45h
jaeger-agent             ClusterIP      None             <none>        5775/UDP,6831/UDP,6832/UDP                                                                                                   45h
jaeger-collector         ClusterIP      10.96.91.234     <none>        14267/TCP,14268/TCP,14250/TCP                                                                                                45h
jaeger-query             ClusterIP      10.98.226.215    <none>        16686/TCP                                                                                                                    45h
kiali                    ClusterIP      10.104.29.238    <none>        20001/TCP                                                                                                                    45h
prometheus               ClusterIP      10.104.5.36      <none>        9090/TCP                                                                                                                     45h
tracing                  ClusterIP      10.106.130.227   <none>        80/TCP                                                                                                                       45h
zipkin                   ClusterIP      10.109.148.252   <none>        9411/TCP  
```

 Notice the grafana ports and the grafana pod name.

 TODO introduce citadel, galley, policy, tracing, prometheus, jaeger-collector, etc.

 Notice that the `istio-ingressgateway` is a `LoadBalancer` and it is pending.
 This is because we are using MiniKube. Minkiube has a feature called tunnel.
 The `minikube tunnel` command creates a route to services deployed with type
 `LoadBalancer`. When we enable that (pretty soon), you will see pending move to ready.

## Let's look at Grafana and some other services.

We can use `port-forward` to get access to any of these services that have an HTTP end point.

The `kubectl` `port-forward` command will forward one or more local ports to a pod.


In a new terminal issue these two commands to get the Grafana pod name and add a port forward
to your local machine so that you can access Grafana via your local browser.

#### Grafana port forward set up-Use kubectl port-forward to access grafana in its own terminal window
```sh
GRAFANA_PORT=$(kubectl -n istio-system get svc | grep grafana | awk '{split($5, port, "/"); print port[1]}' )
GRAFANA_POD_NAME=$(kubectl -n istio-system get pod | grep grafana | awk '{print $1}')
kubectl -n istio-system port-forward $GRAFANA_POD_NAME $GRAFANA_PORT:$GRAFANA_PORT

### Output
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
```

Create a script call `util/openGrafanaPort.sh ` that runs the above.

#### util/openGrafanaPort.sh

```sh
#!/bin/bash
GRAFANA_PORT=$(kubectl -n istio-system get svc | grep grafana | awk '{split($5, port, "/"); print port[1]}' )
GRAFANA_POD_NAME=$(kubectl -n istio-system get pod | grep grafana | awk '{print $1}')
kubectl -n istio-system port-forward $GRAFANA_POD_NAME $GRAFANA_PORT:$GRAFANA_PORT

```

Above we set up the Grafana port forward so we can access it from a browser locally using port-forward.
You ran this in its own terminal. Leave it running.

Now you can access grafana from http://localhost:3000.

Open up Grafana in a browser, click on Home, select Istio Galley Dashboard.

#### Istio Galley Dashboard
![image](https://user-images.githubusercontent.com/382678/76132661-ed722480-5fc8-11ea-8ec1-3537d7a6a5b3.png)

Repeat and select the Istio Mixer Dashboard.

#### Istio Mixer Dashboard
![image](https://user-images.githubusercontent.com/382678/76132796-94ef5700-5fc9-11ea-8c6a-147ef3213bad.png)

---


## MiniKube tunnel so we can use grafana and friends

The `minikube tunnel` command creates a route to services deployed with type
`LoadBalancer` and sets their Ingress to their `ClusterIP` see ([minikube loadbalancer](https://minikube.sigs.k8s.io/docs/tasks/loadbalancer) for more details).

To start up Minikube Tunnel (you will need sudo access) so enter your password when prompted.
Run `minikube` tunnel in a separate terminal.

#### Running minikube tunnel in its own
```sh
$ minikube tunnel
```

---


Now that we have `minikube tunnel` running, we should be able to access services more readily.
If the service is a `loadbalancer`, it will exposed via the `MiniKube tunnel`.

Notice that the `istio-ingressgateway` is a `LoadBalancer` and it was in the pending.
Now it should be ready and have an external ip address.

#### Istio ingressgateway is ready and has external IPs

```sh
$ kubectl -n istio-system get svc -l app=istio-ingressgateway
NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP ...                                                                                               
istio-ingressgateway   LoadBalancer   10.107.13.254   10.107.13.254   15020:31018/TCP,
```





____

## Setting up the gateway

This section explains how to set up a [gateway](https://istio.io/docs/tasks/traffic-management/ingress/ingress-control/#determining-the-ingress-ip-and-ports).

Set up the gateway so we can access the services.

```sh
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export INGRESS_HOST=$(minikube ip)

env | grep INGRESS

### Output
INGRESS_PORT=30851
SECURE_INGRESS_PORT=31073
INGRESS_HOST=192.168.64.18
```

## Setting up the gateway

```sh
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
```

#### Create that as a file set_up_gateway.sh as you will use it again
```sh
 $ mkdir util
 $ touch util/set_up_gateway.sh
 $ atom set_up_gateway.sh
 $ chmod +x util/set_up_gateway.sh
```

#### util/set_up_gateway.sh

```sh
#!/bin/bash

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export INGRESS_HOST=$(minikube ip)
env | grep INGRESS
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

```

#### Apply the gateway networking

This will create routes to `productpage`.

#### Apply routes to BookInfo sample microservices

```sh
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl apply -f samples/bookinfo/networking/destination-rule-all-mtls.yaml
```


#### samples/bookinfo/networking/bookinfo-gateway.yaml

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: bookinfo-gateway
spec:
  selector:
    istio: ingressgateway # use istio default controller
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: bookinfo
spec:
  hosts:
  - "*"
  gateways:
  - bookinfo-gateway
  http:
  - match:
    - uri:
        exact: /productpage
    - uri:
        prefix: /static
    - uri:
        exact: /login
    - uri:
        exact: /logout
    - uri:
        prefix: /api/v1/products
    route:
    - destination:
        host: productpage
        port:
          number: 9080

```

TODO explain what a gateway is and VirtualService

#### samples/bookinfo/networking/destination-rule-all-mtls.yaml

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: productpage
spec:
  host: productpage
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
  subsets:
  - name: v1
    labels:
      version: v1
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews
spec:
  host: reviews
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
  - name: v3
    labels:
      version: v3
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: ratings
spec:
  host: ratings
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
  - name: v2-mysql
    labels:
      version: v2-mysql
  - name: v2-mysql-vm
    labels:
      version: v2-mysql-vm
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: details
spec:
  host: details
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
---

```

TODO Explain DestinationRule(s), ISTIO_MUTUAL and subsets.


See that you have ingress gateway installed.

At this point you should be able to curl the `productpage` and verify that the gateway is working.

#### Test gateway

```sh
$ curl http://$GATEWAY_URL/productpage

### Output
<!DOCTYPE html>
<html>
  <head>
    <title>Simple Bookstore App</title>
    ...
```

Testing the gateway was easy, we just curl against the gateway URL and get the webpage.
____

____

## We could expose other services easily by using

Set up logging (https://istio.io/docs/tasks/observability/logs/access-log/). TBD explain this more.

## Logging

Next you will want to set up the Elasticsearch, FluentD, Kibana logging, which is called the EFK stack.

####  Apply the telemetry file
```sh
kubectl apply -f samples/bookinfo/telemetry/log-entry.yaml
```

#### samples/bookinfo/telemetry/log-entry.yaml

```sh
# Configuration for logentry instances
apiVersion: config.istio.io/v1alpha2
kind: instance
metadata:
  name: newlog
  namespace: istio-system
spec:
  compiledTemplate: logentry
  params:
    severity: '"warning"'
    timestamp: request.time
    variables:
      source: source.labels["app"] | source.workload.name | "unknown"
      user: source.user | "unknown"
      destination: destination.labels["app"] | destination.workload.name | "unknown"
      responseCode: response.code | 0
      responseSize: response.size | 0
      latency: response.duration | "0ms"
    monitored_resource_type: '"UNSPECIFIED"'
---
# Configuration for a stdio handler
apiVersion: config.istio.io/v1alpha2
kind: handler
metadata:
  name: newloghandler
  namespace: istio-system
spec:
  compiledAdapter: stdio
  params:
    severity_levels:
      warning: 1 # Params.Level.WARNING
    outputAsJson: true
---
# Rule to send logentry instances to a stdio handler
apiVersion: config.istio.io/v1alpha2
kind: rule
metadata:
  name: newlogstdio
  namespace: istio-system
spec:
  match: "true" # match for all requests
  actions:
   - handler: newloghandler
     instances:
     - newlog
---

```

#### Curl the product page
```sh
curl http://$GATEWAY_URL/productpage
```


### Check the mixer telemetry  logs
```sh
$ kubectl logs -n istio-system -l istio-mixer-type=telemetry -c mixer | grep "newlog" | grep -v '"destination":"telemetry"' | grep -v '"destination":"pilot"' | grep -v '"destination":"policy"' | grep -v '"destination":"unknown"'

{"level":"warn","time":"2020-03-04T07:27:06.857376Z","instance":"newlog.instance.istio-system","destination":"productpage","latency":"27.058113ms","responseCode":200,"responseSize":5179,"source":"istio-ingressgateway","user":"unknown"}
{"level":"warn","time":"2020-03-04T07:27:07.882016Z","instance":"newlog.instance.istio-system","destination":"productpage","latency":"15.331583ms","responseCode":200,"responseSize":4183,"source":"istio-ingressgateway","user":"unknown"}
{"level":"warn","time":"2020-03-04T07:27:08.870712Z","instance":"newlog.instance.istio-system","destination":"productpage","latency":"24.967486ms","responseCode":200,"responseSize":5183,"source":"istio-ingressgateway","user":"unknown"}
{"level":"warn","time":"2020-03-04T07:27:09.891720Z","instance":"newlog.instance.istio-system","destination":"productpage","latency":"27.276079ms","responseCode":200,"responseSize":5179,"source":"istio-ingressgateway","user":"unknown"}
{"level":"warn","time":"2020-03-04T07:27:12.533032Z","instance":"newlog.instance.istio-system","destination":"productpage","latency":"23.225209ms","responseCode":200,"responseSize":5183,"source":"istio-ingressgateway","user":"unknown"}
```

#### set up EFK

Let's set up EFK. We use this [EFK setup guide](https://istio.io/docs/tasks/observability/mixer/logs/fluentd/#example-fluentd-elasticsearch-kibana-stack) as our guide.




Create a `logging-stack.yml` as follows.

#### logging-stack.yml
```yaml
# Logging Namespace. All below are a part of this namespace.
apiVersion: v1
kind: Namespace
metadata:
  name: logging
---
# Elasticsearch Service
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch
  namespace: logging
  labels:
    app: elasticsearch
spec:
  ports:
  - port: 9200
    protocol: TCP
    targetPort: db
  selector:
    app: elasticsearch
---
# Elasticsearch Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elasticsearch
  namespace: logging
  labels:
    app: elasticsearch
spec:
  replicas: 1
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
      annotations:
        sidecar.istio.io/inject: "false"
    spec:
      containers:
      - image: docker.elastic.co/elasticsearch/elasticsearch-oss:6.1.1
        name: elasticsearch
        resources:
          # need more cpu upon initialization, therefore burstable class
          limits:
            cpu: 1000m
          requests:
            cpu: 100m
        env:
          - name: discovery.type
            value: single-node
        ports:
        - containerPort: 9200
          name: db
          protocol: TCP
        - containerPort: 9300
          name: transport
          protocol: TCP
        volumeMounts:
        - name: elasticsearch
          mountPath: /data
      volumes:
      - name: elasticsearch
        emptyDir: {}
---
# Fluentd Service
apiVersion: v1
kind: Service
metadata:
  name: fluentd-es
  namespace: logging
  labels:
    app: fluentd-es
spec:
  ports:
  - name: fluentd-tcp
    port: 24224
    protocol: TCP
    targetPort: 24224
  - name: fluentd-udp
    port: 24224
    protocol: UDP
    targetPort: 24224
  selector:
    app: fluentd-es
---
# Fluentd Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fluentd-es
  namespace: logging
  labels:
    app: fluentd-es
spec:
  replicas: 1
  selector:
    matchLabels:
      app: fluentd-es
  template:
    metadata:
      labels:
        app: fluentd-es
      annotations:
        sidecar.istio.io/inject: "false"
    spec:
      containers:
      - name: fluentd-es
        image: gcr.io/google-containers/fluentd-elasticsearch:v2.0.1
        env:
        - name: FLUENTD_ARGS
          value: --no-supervisor -q
        resources:
          limits:
            memory: 500Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: config-volume
          mountPath: /etc/fluent/config.d
      terminationGracePeriodSeconds: 30
      volumes:
      - name: config-volume
        configMap:
          name: fluentd-es-config
---
# Fluentd ConfigMap, contains config files.
kind: ConfigMap
apiVersion: v1
data:
  forward.input.conf: |-
    # Takes the messages sent over TCP
    <source>
      type forward
    </source>
  output.conf: |-
    <match **>
       type elasticsearch
       log_level info
       include_tag_key true
       host elasticsearch
       port 9200
       logstash_format true
       # Set the chunk limits.
       buffer_chunk_limit 2M
       buffer_queue_limit 8
       flush_interval 5s
       # Never wait longer than 5 minutes between retries.
       max_retry_wait 30
       # Disable the limit on the number of retries (retry forever).
       disable_retry_limit
       # Use multiple threads for processing.
       num_threads 2
    </match>
metadata:
  name: fluentd-es-config
  namespace: logging
---
# Kibana Service
apiVersion: v1
kind: Service
metadata:
  name: kibana
  namespace: logging
  labels:
    app: kibana
spec:
  ports:
  - port: 5601
    protocol: TCP
    targetPort: ui
  selector:
    app: kibana
---
# Kibana Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kibana
  namespace: logging
  labels:
    app: kibana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kibana
  template:
    metadata:
      labels:
        app: kibana
      annotations:
        sidecar.istio.io/inject: "false"
    spec:
      containers:
      - name: kibana
        image: docker.elastic.co/kibana/kibana-oss:6.1.1
        resources:
          # need more cpu upon initialization, therefore burstable class
          limits:
            cpu: 1000m
          requests:
            cpu: 100m
        env:
          - name: ELASTICSEARCH_URL
            value: http://elasticsearch:9200
        ports:
        - containerPort: 5601
          name: ui
          protocol: TCP
---
```


TODO explain this.


Now install this logging stack which installs EFK.

### Install EFK into the cluster.
```sh
kubectl apply -f logging-stack.yml  


### Output

namespace/logging created
service/elasticsearch created
deployment.apps/elasticsearch created
service/fluentd-es created
deployment.apps/fluentd-es created
configmap/fluentd-es-config created
service/kibana created
deployment.apps/kibana created
```


#### See that EFK is installed in the logging namespace

```sh
$ kubens

### Output
bookinfo
default
istio-system
kube-node-lease
kube-public
kube-system
logging

## Switch to the namespace logging
$ kubens logging

### Output
Context "minikube" modified.
Active namespace is "logging".


### Get the pods
$ kubectl get pods
NAME                             READY   STATUS    RESTARTS   AGE
elasticsearch-7574dc448c-n6qkj   1/1     Running   0          69s
fluentd-es-74854b8768-lddld      1/1     Running   0          69s
kibana-554ffd4fd8-dxdvc          1/1     Running   0          69s

```

You can see that elasticsearch, fluentd and kibana are running.

Now let's open up Kibana and do some poking around.

First we have to open up the port like we did for Grafana.
Create a file called util/openKibanaPort.sh

#### util/openKibanaPort.sh
```sh
#!/bin/bash
KIBANA_PORT=$(kubectl -n logging get svc | grep kibana | awk '{split($5, port, "/"); print port[1]}')
KIBANA_POD_NAME=$(kubectl -n logging get pod | grep kibana | awk '{print $1}')
kubectl -n logging port-forward $KIBANA_POD_NAME $KIBANA_PORT:$KIBANA_PORT

```

Now open up a new terminal and run it.

####  Run openKibanaPort.sh

```sh
$ pwd
/Users/richardhightower/istio/istio-1.4.5
(⎈ |minikube:logging)richardhightower@Richards-MacBook-Pro istio-1.4.5 %

$ cd util
(⎈ |minikube:logging)richardhightower@Richards-MacBook-Pro util %

$ ./openKibanaPort.sh

### Output
Forwarding from 127.0.0.1:5601 -> 5601
Forwarding from [::1]:5601 -> 5601
```


## Run fluetnd telemetry

```sh
kubectl apply -f samples/bookinfo/telemetry/fluentd-istio.yaml

### Output
instance.config.istio.io/newlog configured
handler.config.istio.io/handler created
rule.config.istio.io/newlogtofluentd created

```



#### samples/bookinfo/telemetry/fluentd-istio.yaml

```yaml
# Configuration for logentry instances
apiVersion: config.istio.io/v1alpha2
kind: instance
metadata:
  name: newlog
  namespace: istio-system
spec:
  compiledTemplate: logentry
  params:
    severity: '"info"'
    timestamp: request.time
    variables:
      source: source.labels["app"] | source.workload.name | "unknown"
      user: source.user | "unknown"
      destination: destination.labels["app"] | destination.workload.name | "unknown"
      responseCode: response.code | 0
      responseSize: response.size | 0
      latency: response.duration | "0ms"
    monitored_resource_type: '"UNSPECIFIED"'
---
# Configuration for a Fluentd handler
apiVersion: config.istio.io/v1alpha2
kind: handler
metadata:
  name: handler
  namespace: istio-system
spec:
  compiledAdapter: fluentd
  params:
    address: "fluentd-es.logging:24224"
---
# Rule to send logentry instances to the Fluentd handler
apiVersion: config.istio.io/v1alpha2
kind: rule
metadata:
  name: newlogtofluentd
  namespace: istio-system
spec:
  match: "true" # match for all requests
  actions:
   - handler: handler
     instances:
     - newlog
---

```


#### Now hit the product page a few times
```sh
source util/set_up_gateway.sh  
for i in {0..3}; do curl http://$GATEWAY_URL/productpage; done
```

* Now go open up the browser to http://localhost:5601 to open the Kibana web ui.
* Click `Set up index pattern` in the right hand corner.
* For Index Pattern select `*`.
* Hit Next then select @timestamp from the `Time Filter field name` drop down
* Then click `Create index pattern` button
* Then click `Discover` on the left hand navigation.


You should see something like this:

#### Kibana showing access logs
![image](https://user-images.githubusercontent.com/382678/76135348-1b606480-5fdb-11ea-838c-0d163a91dc56.png)





____

## Jaeger


TODO Describe Jaeger.

Now let us look at [Jaeger](https://istio.io/docs/tasks/observability/distributed-tracing/jaeger/) which will allow us to look at open trace data.

The easiest way to look at Jaeger trace data and spans it to use `istioctl dashboard`.

The `istioctl dashboard` allows access to Istio web UIs, namely:

* controlz    Open ControlZ web UI
* envoy       Open Envoy admin web UI
* grafana     Open Grafana web UI
* jaeger      Open Jaeger web UI
* kiali       Open Kiali web UI
* prometheus  Open Prometheus web UI
* zipkin      Open Zipkin web UI

#### Use istioctl dashboard jaeger to see the jaeger dashboard

```sh

 istioctl dashboard jaeger

 ### Output
 http://localhost:60605

```

It should load launch your default browser. If Safari does not work, copy the URL to Firefox or Chrome.


#### Hit product page a bunch and see what happens in jaeger

```sh

$ source util/set_up_gateway.sh

### Output
INGRESS_PORT=30851
SECURE_INGRESS_PORT=31073
INGRESS_HOST=192.168.64.18

$ for i in `seq 1 100`; do curl -s -o /dev/null http://$GATEWAY_URL/productpage; done


```

In the Jaeger Web UI do the following:

* Select service 'productpage.bookinfo'
* Select operations all
* Click the Find Traces Button.

You should See the following.

#### Product Page Trace Data in Jaeger

![image](https://user-images.githubusercontent.com/382678/76135597-1c929100-5fdd-11ea-8ec4-e55feef6995e.png)


Now click on a span. Any span.

#### Product Page Trace Data in Jaeger
![image](https://user-images.githubusercontent.com/382678/76135628-801cbe80-5fdd-11ea-8af1-7f01629a97ce.png)

You can see the service call stacks and timings between calls.
____

## Kiali Visualize

#### Use istioctl dashboard kiali to see the kiali dashboard

```sh

istioctl dashboard kiali

```

* Log in with the credentials you set up at the very start.
* Select Graph from the far left hand navigation
* Select the namespace `bookinfo` from the top middle left dropdown.

![image](https://user-images.githubusercontent.com/382678/76135705-6a5bc900-5fde-11ea-9fe2-e4b11ec54e96.png)


## Conclusion
Now you are all set up and we can start trying stuff out with Istio.

## Resources  
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
