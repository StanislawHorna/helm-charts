# netbox

A Helm chart for deploying NetBox, the premier infrastructure resource modeling (IRM) application designed to empower network automation. This chart packages the NetBox application with an integrated Redis cache, CloudNativePG PostgreSQL database support, and Vault credential integration.

## Key Features

- **Infrastructure Resource Modeling**: Deploys the NetBox server and worker components for robust IPAM and DCIM.
- **Integrated Caching**: Includes a built-in Redis cache for optimized performance.
- **Database Integration**: Ready to connect with a CloudNativePG PostgreSQL database, utilizing Vault for secure credentials.
- **Vault & External Secrets**: Automatically retrieves/generates admin credentials, database credentials, and Authentik OAuth/OIDC secrets from HashiCorp Vault.
- **Gateway API Routing**: Leverages Traefik and Kubernetes Gateway API's `HTTPRoute` for modern traffic routing.
- **Persistent Media**: Configurable PersistentVolumeClaim for media storage (images, attachments).
- **Root CA Trust Injection**: Easily mount self-signed certificate authority (CA) certs to establish secure TLS connections to external services.

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

2. Configure your options in `charts/netbox/values.yaml`.

3. Install the chart:
   ```bash
   helm upgrade --install netbox ./charts/netbox \
     --namespace netbox \
     --create-namespace
   ```

## Repository Structure

- `charts/netbox/`: The primary chart directory.
  - `templates/`: Kubernetes manifests including deployment for server and worker, services, redis cache, postgresql cluster definition, external-secrets integration, and gateway routing.
  - `values.yaml`: Main configuration settings.

## Configuration

The following table highlights the core configuration parameters.

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `netbox.image.tag` | NetBox application image tag | `latest-5.0.2` |
| `netbox.adminBootstrap.username` | Default admin username | `admin` |
| `netbox.adminBootstrap.email` | Default admin email | `admin@example.com` |
| `netbox.persistence.media.size` | Size of the media volume | `20Gi` |
| `generateAuthentikOAuthSecrets.enabled` | Enable generating OAuth/OIDC secrets with Authentik | `true` |
| `gateway.enabled` | Enable Kubernetes Gateway API `HTTPRoute` | `true` |
| `gateway.hostname` | Hostname for the NetBox web UI | `netbox.example.com` |
| `database.storageClass` | Storage class for PostgreSQL database | `local-path-static` |
| `netbox.server.resources.limits.memory` | Memory limit for the NetBox server pod | `2Gi` |
| `netbox.worker.resources.limits.memory` | Memory limit for the NetBox worker pod | `2Gi` |
| `cache.resources.limits.memory` | Memory limit for the Redis cache pod | `2Gi` |
