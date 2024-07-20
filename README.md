# Homelab

This is a replacement for my basic docker based homelab setup (found at https://github.com/twitchel/smart-home-docker)

I'm starting this setup again from scratch in order to make it a bit more structured. It is also a great use-case to learn Kubernetes.

## Requirements
These dependencies need to be installed on then machine you will be using to orchestrate the build and deploy of this cluster.
You should install them using your package manager of choice

- kubectl
- helm
- kustomize
- k3sup

## Tech Stack
- Kubernetes (k3s in particular)
- k3sup (for deploying k3s)
- Helm (for deploying applications)
- Kustomize (for managing k8s manifests)

## Applications

- Homarr (Home page)

## Getting Started
1. [Creating your nodes](./docs/1-creating-nodes.md)
2. [Kubernetes Setup on Nodes](./docs/2-kubernetes-setup-on-nodes.md)


## References
- https://github.com/JamesTurland/JimsGarage/
- https://greg.jeanmart.me/2020/04/13/build-your-very-own-self-hosting-platform-wi/
- https://devops.stackexchange.com/questions/16013/k3s-the-connection-to-the-server-localhost8080-was-refused-did-you-specify-t
- https://mbuffa.github.io/tips/20210720-kustomize-environment-variables/
