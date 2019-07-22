# Kubernetes cluster up & running using Terraform
**NOTE: This is NOT production-ready**
## Prerequisite:
- A billing Digital Ocean account
- A valid domain name
- kubectl
```sh
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.0", GitCommit:"e8462b5b5dc2584fdcd18e6bcfe9f1e4d970a529", GitTreeState:"clean", BuildDate:"2019-06-20T04:49:16Z", GoVersion:"go1.12.6", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"14", GitVersion:"v1.14.3", GitCommit:"5e53fd6bc17c0dec8434817e69b04a25d8ae0ff0", GitTreeState:"clean", BuildDate:"2019-06-06T01:36:19Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
```
- Helm
```sh
$ helm version
Client: &version.Version{SemVer:"v2.14.2", GitCommit:"a8b13cc5ab6a7dbef0a58f5061bcc7c0c61598e7", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.14.0", GitCommit:"05811b84a3f93603dd6c2fcfe57944dfa7ab7fd0", GitTreeState:"clean"}
```

- doctl
```sh
$ doctl version
doctl version 1.20.1-release
release 1.22.0 is available, check it out!
```

- go
```
$ go version
go version go1.12.7 darwin/amd64
```

## Steps:
- Create a project on Digital Ocean

- Create a `Personal access tokens` (project's dashboad > `API` menu > `Tokens/Keys` tab)

- Clone this repo & run:
```sh
$ export DO_TOKEN=...

$ doctl auth init -t $DO_TOKEN

$ terraform init

$ terraform plan -refresh=true -out=terraform.tfplan -var "do_token=$DO_TOKEN" -var "domain_name=<domain_name>"

$ terraform apply "terraform.tfplan"
```
- Go to digital ocean project's dashboad > `Kubernete` menu > kubernetes cluster's detail page > download configuration file and run:

```sh
$ kubectl --kubeconfig="<configuration_file_name>" get nodes

$ doctl kubernetes cluster kubeconfig save <cluster_name>
```

**Note**: terraform may fail in the first time if helm client version & server version are different, if that, run:

```sh
$ helm init --service-account tiller --upgrade --wait
```

and re-run terraform plan & apply cmd:

```sh
$ terraform plan -refresh=true -out=terraform.tfplan -var "do_token=$DO_TOKEN"

$ terraform apply "terraform.tfplan"
```


*Optional*: Import certificate to access kiubernetes dashboard
```sh
$ grep 'client-key-data' <configuration_file_name> | head -n 1 | awk '{print $2}' | base64 -D >> kubecfg.key

$ grep 'client-certificate-data' <configuration_file_name> | head -n 1 | awk '{print $2}' | base64 -D >> kubecfg.crt

$ openssl pkcs12 -export -clcerts -inkey kubecfg.key -in kubecfg.crt -out kubecfg.p12 -name "kubernetes-client"
```
> import `kubecfg.p12` to keychain

- get `kubernete-dashboard` url:
```sh
$ kubctl cluster-info
Kubernetes master is running at https://d5b62d1d-7701-46e1-b5fd-aaec31ce5e88.k8s.ondigitalocean.com
CoreDNS is running at https://d5b62d1d-7701-46e1-b5fd-aaec31ce5e88.k8s.ondigitalocean.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
kubernetes-dashboard is running at https://d5b62d1d-7701-46e1-b5fd-aaec31ce5e88.k8s.ondigitalocean.com/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:https/proxy
```

 - get access token for `kubernete-dashboard`
 ```
 $ kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep kubernetes-dashboard | awk '{print $1}')
 ```

- Go to digital ocean project's dashboad > `Networking` menu > `Domains` add DNS records:
```md
DNS records

| Type |        Hostname                 |        Value       | TTL  |
|------|---------------------------------|--------------------|------|
| A    | <domain_name>                   | <load_balancer_ip> | 3600 |
| A    | *.<domain_name>                 | <load_balancer_ip> | 3600 |

```
*(<load_balancer_ip> can find in `Load Balancer` tab which was created automatically when initialized `treafik`)*


# Install `cert-manager` with `helm`:
### Prerequisite
- Ensure that you are using Helm v2.12.1 or later before installing cert-manager. To check the Helm version you have installed, run helm version on your local machine.

### Steps: [Installing and Configuring Cert-Manager](https://docs.cert-manager.io/en/latest/getting-started/install/kubernetes.html)*

