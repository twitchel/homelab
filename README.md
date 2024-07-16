# Homelab

This is a replacement for my basic docker based homelab setup (found at https://github.com/twitchel/smart-home-docker)

I'm starting this setup again from scratch in order to make it a bit more structured. It is also a great use-case to learn Kubernetes.

## Tech Stack

- Kubernetes (k3s in particular)

## Applications

- Homarr (Home page)

## Getting Started

### Master node

The master node of the cluster needs to be setup using the following set of steps.

1. Set environment variables needed to set correct permissions. This sets the config file so its readable by non-root user, and also disables deployment of the default load balancer and ingress servers used by k3s.

```bash
$ export K3S_KUBECONFIG_MODE="644"
$ export INSTALL_K3S_EXEC=" --disable servicelb --disable traefik"
```

2. Run the k3s installer

```bash
$ curl -sfL https://get.k3s.io | sh -
```

3. Verify k3s is running as a service.

```bash
$ sudo systemctl status k3s
```

4. We need to copy the kube config from the root account into our user dir if we want to be able to run kubectl without the k3s prefixer

```bash
mkdir ~/.kube
sudo k3s kubectl config view --raw | tee ~/.kube/config
chmod 600 ~/.kube/config
```

5. We should now be able to poll the nodes of the cluster to see our mater node returned

```bash
$ kubectl get nodes -o wide

NAME                               STATUS   ROLES                  AGE    VERSION        INTERNAL-IP      EXTERNAL-IP   OS-IMAGE           KERNEL-VERSION     CONTAINER-RUNTIME
vidan-staging-cluster-controller   Ready    control-plane,master   115s   v1.29.6+k3s2   192.168.10.200   <none>        Ubuntu 24.04 LTS   6.8.0-38-generic   containerd://1.7.17-k3s1
```

And we can also check what base services are running on the cluster

```bash
$ kubectl get pods -A -o wide
NAMESPACE     NAME                                     READY   STATUS    RESTARTS   AGE     IP          NODE                               NOMINATED NODE   READINESS GATES
kube-system   coredns-6799fbcd5-hgqjd                  1/1     Running   0          2m24s   10.42.0.4   vidan-staging-cluster-controller   <none>           <none>
kube-system   local-path-provisioner-6f5d79df6-79ckx   1/1     Running   0          2m24s   10.42.0.2   vidan-staging-cluster-controller   <none>           <none>
kube-system   metrics-server-54fd9b65b-fdfj6           1/1     Running   0          2m24s   10.42.0.3   vidan-staging-cluster-controller   <none>           <none>
```

6. You can get the auth token for your master node using the following command:

```bash
$ sudo cat /var/lib/rancher/k3s/server/node-token

# example token
K106edce2ad174510a840ff7e49680fc556f8830173773a1ec1a5dc779a83d4e35b::server:5a9b70a1f5bc02a7cf775f97fa912345
```

The above is a sample token. Be sure to save this in your password manager of choice, it is needed to connect worker nodes to your cluster master node.

### Worker nodes

The process for setting up a worker node is fairly similar to the master, however, we need to set up a few extra environment variables before-hand

```bash
$ export K3S_KUBECONFIG_MODE="644"
# Your master node's IP address
$ export K3S_URL="https://192.168.0.22:6443" 
# The token we saved in the master node setup script
$ export K3S_TOKEN="K106edce2ad174510a840ff7e49680fc556f8830173773a1ec1a5dc779a83d4e35b::server:5a9b70a1f5bc02a7cf775f97fa912345" 
```

Once again, you can run the installer and verify the service is running using:

```bash
$ curl -sfL https://get.k3s.io | sh -
$ sudo systemctl status k3s-agent
```

After this, on the master node you can run the following command to check that the new node has been added to your cluster:

```bash
$ kubectl get nodes -o wide
```

## References
- https://greg.jeanmart.me/2020/04/13/build-your-very-own-self-hosting-platform-wi/
- https://devops.stackexchange.com/questions/16013/k3s-the-connection-to-the-server-localhost8080-was-refused-did-you-specify-t
