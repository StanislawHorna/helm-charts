# forgejo

A Helm chart for deploying a self-hosted software service for Git repository hosting, Forgejo, on Kubernetes. This chart configures the primary Forgejo server, a CloudNativePG (CNPG) managed PostgreSQL database, a containerized Forgejo runner (with optional Docker-in-Docker) for Forgejo Actions, and secure Vault credential injection via External Secrets Operator.

## Key Features

- **High Performance Git Service**: Deploys the rootless, lightweight Forgejo server with dedicated persistent storage for config and repository files.
- **CloudNativePG PostgreSQL**: Integrates with the CloudNativePG (CNPG) operator to automatically manage high-availability database clustering, backups, and replication.
- **Forgejo Actions Runner**: Optionally provisions a Forgejo Runner with built-in Docker-in-Docker (DinD) capability to run CI/CD pipelines natively.
- **Vault & External Secrets**: Automatically retrieves/generates database passwords, admin credentials, and Authentik OAuth secrets from HashiCorp Vault.
- **Gateway API routing**: Leverages Traefik and Kubernetes Gateway API's `HTTPRoute` for modern traffic routing.
- **Root CA Trust Injection**: Easily mount self-signed certificate authority (CA) certs to establish secure, trusted TLS connections across components.

## Getting Started

### Prerequisites

- A Kubernetes cluster (v1.24+)
- Helm 3.x installed
- [CloudNativePG Operator](https://cloudnative-pg.io/) installed in the cluster
- [External Secrets Operator](https://external-secrets.io/) and access to a HashiCorp Vault instance
- [Gateway API](https://gateway-api.sigs.k8s.io/) CRDs and Traefik (or another compatible Gateway provider) installed

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/stanislawhorna/helm-charts.git
   cd helm-charts
   ```

2. Configure your options in `charts/forgejo/values.yaml`.

3. Install the chart:
   ```bash
   helm upgrade --install forgejo ./charts/forgejo \
     --namespace forgejo \
     --create-namespace
   ```

## Repository Structure

- `charts/forgejo/`: The primary chart directory.
  - `templates/`: Kubernetes manifests.
    - `cnpg/`: PostgreSQL database cluster definition.
    - `runner/`: Deployment manifest for the Forgejo Runner.
    - `server/`: Deployments, Services, ConfigMaps, and routes for the Forgejo server.
  - `values.yaml`: Main configuration settings.

## Configuration

The following table highlights the core configuration parameters.

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `forgejo.rootUrl` | The public base URL of the Forgejo instance | `https://forgejo.example.com` |
| `forgejo.image.tag` | Forgejo server image tag | `15.0.5-rootless` |
| `forgejo.generateAuthentikOAuthSecrets.enabled` | Enable generating OAuth secrets with Authentik | `true` |
| `forgejoRunner.enabled` | Provisions a CI/CD Runner for Forgejo Actions | `true` |
| `forgejoRunner.dockerInDocker.enabled` | Enable Docker-in-Docker sidecar for containerized jobs | `true` |
| `secretsGenerator.kvName` | Path / Engine name in HashiCorp Vault | `k8s-dev` |
| `selfSingedRootCA.enabled` | Mount a custom self-signed Root CA cert for SSL/TLS verification | `true` |
| `gateway.enabled` | Enable Kubernetes Gateway API `HTTPRoute` | `true` |
| `gateway.hostname` | Domain name target for Gateway API routing | `forgejo.example.com` |
| `database.storageClass` | Storage class for PostgreSQL database volume | `local-path-static` |
| `persistence.repositoryFiles.storageClass` | Storage class for Git repository files | `nfs-storage-static` |
| `persistence.repositoryFiles.size` | Size of Git repositories volume | `50Gi` |
