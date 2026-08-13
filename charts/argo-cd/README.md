# Argo-CD

A minimal custom Helm chart for deploying Argo CD, a declarative GitOps continuous delivery tool for Kubernetes. This chart is tailored for the repository's ecosystem, providing streamlined configurations for integration with Vault, Authentik, and Traefik Gateway API.

## Key Features

- **GitOps Continuous Delivery**: Deploys the core Argo CD components (Server, Repo Server, Application Controller, ApplicationSet Controller) for automated deployment and lifecycle management.
- **Vault & External Secrets**: Automatically retrieves/generates admin credentials, cluster access secrets, and Authentik OAuth/OIDC secrets from HashiCorp Vault.
- **Multi-Cluster Support**: Easily manage and deploy to multiple target Kubernetes clusters securely using secrets stored in Vault.
- **Gateway API Routing**: Leverages Traefik and Kubernetes Gateway API's `HTTPRoute` for modern traffic routing to the Argo CD UI/API.
- **Root CA Trust Injection**: Easily mount self-signed certificate authority (CA) certs to establish secure, trusted TLS connections across components (especially for connecting to private Git repositories).
- **Integrated Redis Cache**: Includes a local Redis instance for improved performance and responsiveness.
- **EnvFrom Support**: Supports mapping configuration from ConfigMaps or Secrets directly to environment variables for simplified configuration.

## Getting Started

### Prerequisites

- A Kubernetes cluster (v1.24+)
- Helm 3.x installed
- [External Secrets Operator](https://external-secrets.io/) and access to a HashiCorp Vault instance
- [Gateway API](https://gateway-api.sigs.k8s.io/) CRDs and Traefik (or another compatible Gateway provider) installed

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/stanislawhorna/helm-charts.git
   cd helm-charts
   ```

2. Configure your options in `charts/argo-cd/values.yaml`.

3. Install the chart:
   ```bash
   helm upgrade --install argo-cd ./charts/argo-cd \
     --namespace argocd \
     --create-namespace
   ```

## Repository Structure

- `charts/argo-cd/`: The primary chart directory.
  - `templates/`: Kubernetes manifests including the various controllers, server, repo-server, redis, config, and external secrets integration.
  - `values.yaml`: Main configuration settings.

## Configuration

The following table highlights the core configuration parameters.

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `argoCd.inClusterName` | Name for the local cluster | `dev-cluster` |
| `argoCd.cdRepo.url` | URL of the central CD repository | `https://forgejo.example.com/<org>/<repo>.git` |
| `argoCd.cdRepo.path` | Path within the repo for the root app | `bootstrap` |
| `argoCd.clusters` | List of target clusters to manage | `[]` (see `values.yaml` for examples) |
| `images.argocd.tag` | Argo CD image tag | `v3.5.0` |
| `gateway.enabled` | Enable Kubernetes Gateway API `HTTPRoute` | `true` |
| `gateway.hostname` | Hostname for the Argo CD web UI | `argocd.example.com` |
| `redis.enabled` | Enable embedded Redis | `true` |
| `generateAuthentikOAuthSecrets.enabled` | Enable generating OAuth/OIDC secrets with Authentik | `true` |
| `bootstrap.enabled` | Enable bootstrap secrets generation via Vault | `true` |
| `selfSingedRootCA.enabled` | Mount a custom self-signed Root CA cert for SSL/TLS verification | `true` |
| `server.replicaCount` | Number of Argo CD Server replicas | `1` |
| `controller.replicaCount` | Number of Application Controller replicas | `1` |
| `repoServer.replicaCount` | Number of Repo Server replicas | `1` |
| `applicationset.replicaCount` | Number of ApplicationSet Controller replicas | `1` |
