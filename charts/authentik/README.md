# authentik

A Helm chart for deploying authentik, an open-source Identity Provider focused on flexibility and versatility. It sets up the primary authentik server, background workers, a CloudNativePG (CNPG) managed PostgreSQL database with scheduled S3 backups, and secure Vault credential injection via External Secrets Operator.

## Key Features

- **SSO & Identity Provider**: Supports OAuth2/OIDC, SAML, LDAP, and custom authentication flows.
- **CloudNativePG PostgreSQL**: Integrates with the CloudNativePG (CNPG) operator to automatically manage high-availability database clustering and replication.
- **Automated S3 Backups**: Pre-configured CNPG S3 backups targeting object storage (e.g. MinIO, rust-fs, or AWS S3) with credentials dynamically synced from HashiCorp Vault.
- **Vault & External Secrets**: Automatically retrieves/generates database passwords, admin credentials, and bootstrap secrets from HashiCorp Vault.
- **Gateway API routing**: Leverages Traefik and Kubernetes Gateway API's `HTTPRoute` for modern traffic routing.
- **Optimized Resources**: Predefined resource limits and requests for both server and worker pods to ensure steady performance.

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

2. Configure your options in `charts/authentik/values.yaml`.

3. Install the chart:
   ```bash
   helm upgrade --install authentik ./charts/authentik \
     --namespace authentik \
     --create-namespace
   ```

## Repository Structure

- `charts/authentik/`: The primary chart directory.
  - `templates/`: Kubernetes manifests.
    - `cnpg/`: PostgreSQL database cluster definition and backup configuration.
    - `server/`: Deployment, Service, and route manifests for the Authentik server.
    - `worker/`: Deployment manifest for the Authentik background task worker.
  - `values.yaml`: Main configuration settings.
  - `dev-values.yaml`: Pre-configured settings for local development.

## Configuration

The following table highlights the core configuration parameters.

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `image.tag` | Authentik container image tag | `2026.2.3` |
| `authentikBootstrap.adminEmail` | Default email for the bootstrapped admin user | `admin@example.com` |
| `secretsGenerator.kvName` | Path / Engine name in HashiCorp Vault for secrets generation | `k8s-dev` |
| `gateway.enabled` | Enable Kubernetes Gateway API `HTTPRoute` | `true` |
| `gateway.hostname` | Domain name target for Gateway API routing | `authentik.k0s.stage.horna.local` |
| `database.storageClass` | Storage class for PostgreSQL database volume | `local-path-static` |
| `database.backup.enabled` | Enable automated database backups | `true` |
| `database.backup.schedule` | Cron schedule for database backups | `0 0 * * * *` (hourly) |
| `database.backup.s3Config.destinationPath` | S3 bucket destination path for backups | `s3://authentik-pg-backup/` |
| `server.resources.requests.memory` | Memory request for the authentik server pod | `512Mi` |
| `server.resources.limits.memory` | Memory limit for the authentik server pod | `2Gi` |
| `worker.resources.requests.memory` | Memory request for the authentik worker pod | `512Mi` |
| `worker.resources.limits.memory` | Memory limit for the authentik worker pod | `2Gi` |