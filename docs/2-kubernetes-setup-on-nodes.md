# Kubernetes Setup on Nodes
1. Snapshot your VMs!
2. Update details in script (for now, will be env.json later)
3. Run the script, grab a coffee and enjoy :) (hopefully!)
4. An alias can be created to so you can run commands on an environment
```bash
alias k3stage="kubectl --kubeconfig=$HOME/.kube/config-staging.yaml"
```
[Back](../README.md)