# immich

A Helm chart for deploying Immich, a very high performance self-hosted photo and video backup solution, on Kubernetes. This chart configures the Immich API, microservices, and machine learning containers, along with deep integration for PostgreSQL (with S3 backups), Redis, and NFS for external libraries.

## Key Features

- **High Performance Photo Backup**: Deploys the full Immich stack including the API server, worker microservices, and a dedicated Machine Learning container.
- **External Libraries (NFS)**: Natively supports mounting external libraries (e.g. from a Synology NAS) via NFS directly into the Immich containers.
- **Granular Persistence**: Configurable separate volumes for the library, profiles, thumbnails, encoded videos, and uploads, supporting a mix of local and network storage (NFS).
- **Database & S3 Backups**: Integrates with CloudNativePG for PostgreSQL, including built-in support for automated scheduled database backups to S3-compatible storage.
- **Integrated Caching**: Includes a built-in Redis cache for optimized performance.
- **Vault & External Secrets**: Automatically retrieves/generates database credentials and Authentik OAuth/OIDC secrets from HashiCorp Vault.
- **Gateway API Routing**: Leverages Traefik and Kubernetes Gateway API's `HTTPRoute` for modern traffic routing.
- **Root CA Trust Injection**: Easily mount self-signed certificate authority (CA) certs to establish secure TLS connections across components.

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

2. Configure your options in `charts/immich/values.yaml`.

3. Install the chart:
   ```bash
   helm upgrade --install immich ./charts/immich \
     --namespace immich \
     --create-namespace
   ```

## Repository Structure

- `charts/immich/`: The primary chart directory.
  - `templates/`: Kubernetes manifests including deployment for API, workers, machine learning, services, redis cache, postgresql cluster definition (with backup schedule), external-secrets integration, and gateway routing.
  - `values.yaml`: Main configuration settings.

## Configuration

The following table highlights the core configuration parameters.

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `immich.image.tag` | Immich application image tag | `v3.1.0` |
| `immich.externalLibraries` | List of external NFS libraries to mount | `[{name: nfs-homes, server: 10.0.10.1, share: /volume1/homes}]` |
| `immich.persistence.library.size` | Size of the core library volume | `100Gi` |
| `immich.persistence.uploads.size` | Size of the uploads volume | `300Gi` |
| `immichMachineLearning.image.tag` | Machine learning container image tag | `v3.1.0` |
| `database.storage.size` | Size of the PostgreSQL database | `50Gi` |
| `database.backup.enabled` | Enable scheduled backups to S3 | `false` |
| `generateAuthentikOAuthSecrets.enabled` | Enable generating OAuth/OIDC secrets with Authentik | `true` |
| `gateway.enabled` | Enable Kubernetes Gateway API `HTTPRoute` | `true` |
| `gateway.hostname` | Hostname for the Immich web UI | `immich.example.com` |
| `redisCache.image.tag` | Redis cache image tag | `7-alpine` |
