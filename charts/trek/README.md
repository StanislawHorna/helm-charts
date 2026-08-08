# Trek

A Helm chart for deploying Trek, a self-hosted, real-time collaborative travel planner — with maps, budgets, packing lists, a journal, on Kubernetes. This chart packages the Trek web application with persistent storage for data, uploads, and backups, and integrates with HashiCorp Vault via External Secrets Operator for secure credentials management.

## Key Features

- **Persistent Storage**: Configurable PersistentVolumeClaims for application data, user uploads, and automated backups with independent storage class support.
- **Vault & External Secrets**: Automatically retrieves/generates admin credentials, encryption keys, and Authentik OAuth/OIDC secrets from HashiCorp Vault.
- **Gateway API Routing**: Leverages Traefik and Kubernetes Gateway API's `HTTPRoute` for modern traffic routing.
- **Root CA Trust Injection**: Easily mount self-signed certificate authority (CA) certs to establish secure, trusted TLS connections across components.
- **Health Monitoring**: Built-in liveness and readiness probes for reliable pod lifecycle management.

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

2. Configure your options in `charts/trek/values.yaml`.

3. Install the chart:
   ```bash
   helm upgrade --install trek ./charts/trek \
     --namespace trek \
     --create-namespace
   ```

## Repository Structure

- `charts/trek/`: The primary chart directory.
  - `templates/`: Kubernetes manifests including deployment, service, configmap, PVCs, external-secrets, http-route, and secrets-job.
  - `values.yaml`: Main configuration settings.

## Configuration

The following table highlights the core configuration parameters.

| Parameter                                    | Description                                                      | Default                    |
| :------------------------------------------- | :--------------------------------------------------------------- | :------------------------- |
| `trek.rootUrl`                               | The public base URL of the Trek instance                         | `https://trek.example.com` |
| `trek.image.tag`                             | Trek application image tag                                       | `3.4.1`                    |
| `trek.environment`                           | Application environment mode                                     | `production`               |
| `trek.adminBootstrap.enabled`                | Enable admin user bootstrapping via Vault                        | `true`                     |
| `trek.adminBootstrap.email`                  | Default admin email                                              | `admin@example.com`        |
| `trek.generateAuthentikOAuthSecrets.enabled` | Enable generating OAuth/OIDC secrets with Authentik              | `true`                     |
| `trek.gateway.enabled`                       | Enable Kubernetes Gateway API `HTTPRoute`                        | `true`                     |
| `selfSingedRootCA.enabled`                   | Mount a custom self-signed Root CA cert for SSL/TLS verification | `true`                     |
| `persistence.data.size`                      | Size of the application data volume                              | `10Gi`                     |
| `persistence.uploads.size`                   | Size of the user uploads volume                                  | `10Gi`                     |
| `persistence.backups.size`                   | Size of the backups volume                                       | `30Gi`                     |
| `resources.requests.memory`                  | Memory request for the Trek pod                                  | `256Mi`                    |
| `resources.limits.memory`                    | Memory limit for the Trek pod                                    | `512Mi`                    |
