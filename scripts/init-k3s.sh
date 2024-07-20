#!/bin/bash

#############################################
# YOU SHOULD ONLY NEED TO EDIT THIS SECTION #
#############################################

deployEnv=staging

# Set run from dir
PWD=$1

# Artefacts go here
outputDir="$PWD/output/$deployEnv"
rm -rf $outputDir
mkdir -p $outputDir

# User of local machine
localUser=$(whoami)

# Version of Kube-VIP to deploy
KVVERSION="v0.6.3"

# K3S Version
k3sVersion="v1.26.10+k3s2"

# Set the IP addresses of the master and work nodes
master1=192.168.10.201
master2=192.168.10.202
master3=192.168.10.203
worker1=192.168.10.204
worker2=192.168.10.205

# User of remote machines
remoteUser=ubuntu

# Interface used on remotes
interface=eth0

# Set the virtual IP address (VIP)
vip=192.168.10.210

# Array of master nodes
masters=($master2 $master3)

# Array of worker nodes
workers=($worker1 $worker2)

# Array of all
all=($master1 $master2 $master3 $worker1 $worker2)

# Array of all minus master
allnomaster1=($master2 $master3 $worker1 $worker2)

#Loadbalancer IP range
lbrange=192.168.10.211-192.168.10.250

#ssh certificate name variable
certName=k3s-$deployEnv

kubeConfigDir="$HOME/.kube"
kubeConfigPath="$kubeConfigDir/config-$deployEnv"
kubeConfigArgs="--kubeconfig=$kubeConfigPath"

# Install policycoreutils for each node
for newnode in "${all[@]}"; do
  ssh $remoteUser@$newnode -i ~/.ssh/$certName sudo su <<EOF
  sudo timedatectl set-ntp off
  sudo timedatectl set-ntp on
  NEEDRESTART_MODE=a apt install policycoreutils -y
  exit
EOF
  echo -e " \033[32;5mPolicyCoreUtils installed!\033[0m"
done

# Step 1: Bootstrap First k3s Node
mkdir -p $kubeConfigDir
k3sup install \
  --ip $master1 \
  --user $remoteUser \
  --tls-san $vip \
  --cluster \
  --k3s-version $k3sVersion \
  --k3s-extra-args "--disable traefik --disable servicelb --flannel-iface=$interface --node-ip=$master1 --node-taint node-role.kubernetes.io/master=true:NoSchedule" \
  --merge \
  --sudo \
  --local-path $kubeConfigPath \
  --ssh-key $HOME/.ssh/$certName \
  --context k3s-ha
echo -e " \033[32;5mFirst Node bootstrapped successfully!\033[0m"

# Step 2: Install Kube-VIP for HA
kubectl $kubeConfigArgs apply -f https://kube-vip.io/manifests/rbac.yaml

# Step 3: Process kube-vip
cat "$PWD/scripts/kube-vip" | sed 's/$interface/'$interface'/g; s/$vip/'$vip'/g' > "$outputDir/kube-vip.yaml"

# Step 4: Copy kube-vip.yaml to master1
scp -i ~/.ssh/$certName "$outputDir/kube-vip.yaml" $remoteUser@$master1:~/kube-vip.yaml

# Step 5: Connect to Master1 and move kube-vip.yaml
ssh $remoteUser@$master1 -i ~/.ssh/$certName <<-EOF
  sudo mkdir -p /var/lib/rancher/k3s/server/manifests
  sudo mv kube-vip.yaml /var/lib/rancher/k3s/server/manifests/kube-vip.yaml
EOF

# Step 6: Add new master nodes (servers) & workers
for newnode in "${masters[@]}"; do
  k3sup join \
    --ip $newnode \
    --user $remoteUser \
    --sudo \
    --k3s-version $k3sVersion \
    --server \
    --server-ip $master1 \
    --ssh-key $HOME/.ssh/$certName \
    --k3s-extra-args "--disable traefik --disable servicelb --flannel-iface=$interface --node-ip=$newnode --node-taint node-role.kubernetes.io/master=true:NoSchedule" \
    --server-user $remoteUser
  echo -e " \033[32;5mMaster node joined successfully!\033[0m"
done

# add workers
for newagent in "${workers[@]}"; do
  k3sup join \
    --ip $newagent \
    --user $remoteUser \
    --sudo \
    --k3s-version $k3sVersion \
    --server-ip $master1 \
    --ssh-key $HOME/.ssh/$certName \
    --k3s-extra-args "--node-label \"longhorn=true\" --node-label \"worker=true\""
  echo -e " \033[32;5mAgent node joined successfully!\033[0m"
done

# Step 7: Install kube-vip as network LoadBalancer - Install the kube-vip Cloud Provider
kubectl $kubeConfigArgs apply -f https://raw.githubusercontent.com/kube-vip/kube-vip-cloud-provider/main/manifest/kube-vip-cloud-controller.yaml

# Step 8: Install Metallb
kubectl $kubeConfigArgs apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl $kubeConfigArgs apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
# Download ipAddressPool and configure using lbrange above
cat "$PWD/scripts/ipAddressPool.yaml.tmpl" | sed 's/$lbrange/'$lbrange'/g' > "$outputDir/ipAddressPool.yaml"
kubectl $kubeConfigArgs apply -f "$outputDir/ipAddressPool.yaml"

# Step 9: Test with Nginx
kubectl $kubeConfigArgs apply -f https://raw.githubusercontent.com/inlets/inlets-operator/master/contrib/nginx-sample-deployment.yaml -n default
kubectl $kubeConfigArgs expose deployment nginx-1 --port=80 --type=LoadBalancer -n default

echo -e " \033[32;5mWaiting for K3S to sync and LoadBalancer to come online\033[0m"

while [[ $(kubectl $kubeConfigArgs get pods -l app=nginx -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
  sleep 1
done

# Step 10: Deploy IP Pools and l2Advertisement
cp "$PWD/scripts/l2Advertisement.yaml" "$outputDir/l2Advertisement.yaml"
kubectl $kubeConfigArgs wait --namespace metallb-system \
  --for=condition=ready pod \
  --selector=component=controller \
  --timeout=120s
kubectl $kubeConfigArgs apply -f "$outputDir/ipAddressPool.yaml"
kubectl $kubeConfigArgs apply -f "$outputDir/l2Advertisement.yaml"

kubectl $kubeConfigArgs get nodes
kubectl $kubeConfigArgs get svc
kubectl $kubeConfigArgs get pods --all-namespaces -o wide

echo -e " \033[32;5mHappy Kubing! Access Nginx at EXTERNAL-IP above\033[0m"
