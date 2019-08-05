# ClusterIP Service
- ClusterIP: Exposes a set of pods to other objects in the cluster(let any object inside node can access to that pod)
- NodePort: Exposes a set of pods to the outside world (only good for dev purpose)

kubectl delete deployment client-deployment

kubectl get service **this will get all the services and one of thoses has name kubernetes, which is origin service, do not touch that **

postgres PVC(Persistent Volume Claim): this will place outside the pods of postgres container so when the pod is deleted or crash the data do not lose at all

- volume in generic container terminology: Some type of machanism that allows container to access a filesystem outside itself

- volume in kubenetes: an object that allows a container to store data at the pod level (persistent volume, PVC) 

so in postgres deployment has a single pod, that pod has single postgres container when we create a volume in kubenetes we are creating a little of data storage pocket that exists or is tied directly to a very specific POD

in kubenetes volume vs persistent volume
- if the postgres containers crash or recreat the volume still exists and auto connect when the new containers is created but the entire pod is crash the volume is gone and all the data is lose ----- the persistent volume is outside the pod, completely separate from the pod so if the pod crash the PV still exists and the new can connect

pv vs pvc
pvc is an advertisement, it's saying hey all the pods inside this cluster you can choose from a static option or dynamic option, when we write our config file we are going to say hey pod need the static option and 
pvc: has provision static(this will create head of time) and provision dynamic(this will create when be asked)

get default storage: kubeclt get storageclass

get more infomation about storageclass: kubeclt describe storageclass

Access modes from database persistent volume claim
have 3 different type AM: 
ReadWriteOne, -->  can be used by single node
ReadOnlyMany, --> multiple node can read from this
ReadWriteMany --> can be read and written to by many nodes

minikube-hostpath: when we ask kubenetes to create this persistent volume it's going to look on the host machine to minikube, it's going to make a little slice of space on your personal hard driver

so at some point in time you and i want to move our application over to a cloud provider and when we are working with a cloud provider we get a tremendous number of different options of where some hard drive space 

# another object Type Secrets 
securely stores a peace of information in the cluster, such as a database password

create a secret

kubectl create secret generic secret_name --from-literal key=value
- create: imperative command to create new object
- secret: type of object we are going to create
- generic: type of secret (another is docker-registry, tls )
- name of secret, for later reference in a pod config
- --from-literal: we are going to add the secret information into this command, as opposed to file
- key=value: key-value pair of the secret information
kubectl create secret generic pgpassword --from-literal PGPASSWORD=tien1991

# another Service type : loadbalancer
- Legacy way of getting network traffic into a cluster

# Ingress-nginx
- setup the ingress-nginx changes depending on your env (local, GC, AWS, Azure)

- Ingress-nginx on google cloud: make an ingress config file and that's going to describe all the routing rules that should exist inside of application, this config is going to be feed into deployment that is running both our controller at the ingress controller and an nginx pod and an nginx pod is what's going to actually take incoming traffic and route it off the the appropriate location, now specifically on GC there is some other pieces in here that get create at the same time as well, so when we make an ingress on GC we are going to get a GC load balancer created for us, once that LB is in effect inside the cluster itself the deployment that gets created is going to get a LB service attached on it

flow:
Traffic --> GC load balancer

so incoming traffic will come to GC load balancer, that balancer is going to send that traffic to load balancer service inside the cluster which is going to eventually get that traffic into nginx pod that's get created by our ingress controller, it's then up to that nginx pod to eventually send that traffic off to the appropriate service inside of our application, other the multi-client or multi-server. Now there is one last little piece of the puzzle here that i just want you to be ware of by default when you set up all this nginx ingree stuff. there is  going to be another deployment setup inside of your cluster, something called a default backend, the defauolt backend is used for a series of health checks to essentially make sure that your cluster is working the way that should be working

# setup ingress-nginx: in local
https://kubernetes.github.io/ingress-nginx/deploy/#prerequisite-generic-deployment-command

1. The following Mandatory Command is required for all deployments.
2. minikube
run this command line
`minikube addons enable ingress`

some command line:
kubectl logs name_pods
kubectl delete --all type_object
minikube dashboard

some very good reason that we are going to use google cloud here as opposed to aws:
- Google created Kubernetes!
- AWS only "Recently" got kubernetes support
- Far, far easier to poke around kubenetes on GC
- Excellent document for beginners

Travis config file for google cloud
- install google cloud skd cli
- configure the sdk with out google cloud auth info
- login to docker CLI
- build the 'test' version of multi-client
- run the test
- if tests are successful, run a script to deploy newest images
- build all our images, tag each other, push each to docker hub
- apply all config in the k8s folder 
- imperatively set latest images on each deployment

auth gcloud with service-account.json
- Create a Service Account
- download service account credentials in a json file
- download and install travis cli
- encrypt and upload the json file to our travis account
- in .travis.yml add code to decrypt the json file and load it into gcloud sdk

install travis cli(this required the ruby, using ruby inside docker)
- docker run -it -v $(pwd):/app ruby:2.3 sh (-v is volume here make the service-account.json file inside the container)
+ gem install travis --no-rdoc --no-ri
+ gem install travis
+ travis login
+ Copy json file into the 'volume' directory so we can use it in the container
+ travis encrypt-file service-account.json + repository with case sensitive (tienvv1234 / multi-k8s)

Please add the following to your build script (before_install stage in your .travis.yml, for instance):
this will generate when we run command line ` travis encrypt-file`
```
    openssl aes-256-cbc -K $encrypted_0c35eebf403c_key -iv $encrypted_0c35eebf403c_iv -in service-account.json.enc -out service-account.json -d
```

tag dockerid/multi-client:latest
tag dockerid/multi-client:$SHA

git SHA is identifying that current set of changes inside of our code base so to print out the SHA that we are currently working with right now : git rev-parse HEAD

flow debug : deployments is running multi-client:SHA --> git checkout SHA --> debug the app knowing the exact code that is running in production
we are using both of 2 tag
-SHA : we are doing SHa to make sure that we can correctly update stuff in production inside of our cluster
-latest: we are still doing the latest to make sure that f we ever have to re clone or rebuild our cluster at some point time, we always know that the latest tag image is truly the latest version of our image

ingress-nginx using Helm
Helm is a program that we can use to administer third party software inside of our communities cluster

helm: helm client tool cli + tiller server

# RBAC (Role Based access controll)
the purpose of RBAC is to limit who can access what different types of resource inside of a kubernetes cluster
- limit who can access and modify objects in our cluster
- enable on google cloud by default
- tiller wants to make changes to our cluster, so it need to get some permissions set

security: User Account, Service Account, ClusterRoleBinding, RoleBinding
UserAccount : Identifies a `person` administering our cluster
ServiceAccount: Identifies a `pod` administering our cluster
ClusterRoleBinding: Authorizes an account to do a certain set of actions cross the entire cluster
RoleBinding: Authorizes an account to do a certain set of actions in a * single namespace*

- the only different thing betwwen clusterROleBinding and RoleBInding is a cluster allows you to make changes across the entire
cluster, role is only going to allow you to do a certain set of actions in a single namespace


So we need to make sure the tiller server has the correct set of permissions so that it can actually make all these different changes

kubectl create serviceaccount --namespace kube-system tiller
- create a new service account called name tiller tiller in the kube-system namespace

kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
create a new cluster role binding with the role `cluster-admin` and assign it to service account `tiller` and name is `tiller-cluster-rule`

after run 2 above command then run `helm init` ==> helm init --service-account tiller --upgrade