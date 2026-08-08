# Outline

A Helm chart for deploying Outline, a fast, collaborative wiki and knowledge base for your team, on Kubernetes. This chart packages the Outline web application, a local Redis cache instance, a CloudNativePG (CNPG) managed PostgreSQL database, and integrates with HashiCorp Vault using External Secrets Operator for secure credentials sync.

## Key Features

- **Collaborative Knowledge Base**: Deploys the Outline application server with built-in rich editing.
- **CloudNativePG PostgreSQL**: Integrates with the CloudNativePG (CNPG) operator to automatically manage high-availability database clustering and replication.
- **Redis Cache Integration**: Provisions an ephemeral Redis instance for session state, search indices, and caching.
- **S3 Object Storage**: Configured for S3-compatible cloud storage (e.g. AWS S3, MinIO, or rust-fs) for hosting document attachments and images.
- **Vault & External Secrets**: Automatically retrieves/generates application secret keys, OIDC credentials, and database passwords from HashiCorp Vault.
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

2. Configure your options in `charts/outline/values.yaml`.

3. Install the chart:
   ```bash
   helm upgrade --install outline ./charts/outline \
     --namespace outline \
     --create-namespace
   ```

## Repository Structure

- `charts/outline/`: The primary chart directory.
  - `templates/`: Kubernetes manifests.
    - `cnpg/`: PostgreSQL database cluster definition.
    - `redis-cache/`: Deployment, Service, and ConfigMaps for the Redis caching instance.
    - `deployment.yaml`: Main deployment manifest for Outline.
    - `external-secrets.yaml`: Synchronizes authentication keys, DB, and OAuth passwords from Vault.
    - `http-route.yaml`: HTTPRoute resources for Gateway API ingress.
    - `service.yaml`: Service definition mapping Outline web port.
  - `values.yaml`: Main configuration settings.

## Configuration

The following table highlights the core configuration parameters.

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `outline.rootURL` | The public base URL of the Outline instance | `https://outline.example.com` |
| `outline.image.tag` | Outline application image tag | `1.9.2` |
| `outline.generateAuthentikOAuthSecrets.enabled` | Enable generating OAuth/OIDC secrets with Authentik | `true` |
| `outline.generateAuthentikOAuthSecrets.authentikHost` | The public host of your Authentik provider | `https://authentik.example.com` |
| `redisCache.resources.limits.memory` | Memory limit for the Redis caching instance | `512Mi` |
| `secretsGenerator.kvName` | Path / Engine name in HashiCorp Vault | `k8s-dev` |
| `selfSingedRootCA.enabled` | Mount a custom self-signed Root CA cert for SSL/TLS verification | `true` |
| `gateway.enabled` | Enable Kubernetes Gateway API `HTTPRoute` | `true` |
| `gateway.hostname` | Domain name target for Gateway API routing | `outline.example.com` |
| `database.storageClass` | Storage class for PostgreSQL database volume | `local-path-static` |
| `storage.s3Config.enabled` | Enable S3 storage configurations for attachments | `true` |
| `storage.s3Config.bucketName` | S3 bucket name for Outline attachments | `outline-data` |
| `storage.s3Config.endpointURL` | Custom S3 endpoint URL (e.g. for MinIO or rust-fs) | `http://rust-fs.rust-fs.svc.cluster.local:9000` |
