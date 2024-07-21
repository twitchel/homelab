# Install Rancher for easier management

Note: `k3stage` is an alias for kubectl with the staging kubeconfig

1. Install helm using your package manager
2. Create an alias to manage your environment easier, i.e.
```bash
alias helmstage="helm --kubeconfig=$HOME/.kube/config-staging.yaml"
```
3. Add the helm repo for rancher
```bash
helmstage repo add rancher-latest https://releases.rancher.com/server-charts/latest
k3stage create namespace cattle-system
```
4. Install the Cert Manager
```bash
k3stage apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml
helmstage repo add jetstack https://charts.jetstack.io
helmstage repo update
helmstage install cert-manager jetstack/cert-manager \
--namespace cert-manager \
--create-namespace \
--version v1.13.2
k3stage get pods --namespace cert-manager
```

5. Install Rancher
```bash
helmstage install rancher rancher-latest/rancher \
 --namespace cattle-system \
 --set hostname=rancher.home-staging.danieljones.net \
 --set bootstrapPassword=admin
k3stage -n cattle-system rollout status deploy/rancher
k3stage -n cattle-system get deploy rancher
```

6. Expose Rancher via Load Balancer
```bash
k3stage get svc -n cattle-system
k3stage expose deployment rancher --name=rancher-lb --port=443 --type=LoadBalancer -n cattle-system
k3stage get svc -n cattle-system 
```