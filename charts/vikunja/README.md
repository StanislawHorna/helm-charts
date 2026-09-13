# vikunja

A Helm chart for deploying Vikunja, a self-hosted, open-source task management application, on Kubernetes. This chart configures the Vikunja application with support for Vault credential integration, Authentik OAuth/OIDC, Traefik Gateway API routing, and local persistence for files and database.

## Key Features

- **Task Management**: Deploys the Vikunja application for efficient to-do list and task management.
- **Vault & External Secrets**: Automatically retrieves/generates application credentials and Authentik OAuth/OIDC secrets from HashiCorp Vault.
- **Gateway API Routing**: Leverages Traefik and Kubernetes Gateway API's `HTTPRoute` for modern traffic routing.
- **Persistent Storage**: Configurable PersistentVolumeClaims for Vikunja files and database storage.
- **Root CA Trust Injection**: Easily mount self-signed certificate authority (CA) certs to establish secure TLS connections to external services.
- **Email Credentials Support**: Optional integration to load email credentials securely from Vault.

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

2. Configure your options in `charts/vikunja/values.yaml`.

3. Install the chart:
   ```bash
   helm upgrade --install vikunja ./charts/vikunja \
     --namespace vikunja \
     --create-namespace
   ```

## Repository Structure

- `charts/vikunja/`: The primary chart directory.
  - `templates/`: Kubernetes manifests including deployment, services, PVCs, external-secrets integration, and gateway routing.
  - `values.yaml`: Main configuration settings.

## Configuration

The following table highlights the core configuration parameters.

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `image.tag` | Vikunja application image tag | `2.6.0` |
| `gateway.enabled` | Enable Kubernetes Gateway API `HTTPRoute` | `true` |
| `gateway.rootUrl` | Hostname/root URL for the Vikunja web UI | `https://vikunja.example.com` |
| `persistence.files.size` | Size of the files volume | `10Gi` |
| `persistence.db.size` | Size of the database volume | `10Gi` |
| `generateAuthentikOAuthSecrets.enabled` | Enable generating OAuth/OIDC secrets with Authentik | `true` |
| `emailCredentials.enabled` | Enable fetching email credentials from Vault | `false` |
| `selfSingedRootCA.enabled` | Mount a custom self-signed Root CA cert for SSL/TLS verification | `true` |
| `resources.limits.memory` | Memory limit for the Vikunja pod | `512Mi` |
