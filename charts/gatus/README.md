# Gatus

A Helm chart for deploying Gatus, an automated service health dashboard and monitoring tool, on Kubernetes. This chart configures Gatus with support for GitOps endpoint synchronization via `git-sync`, local ConfigMap endpoint definitions, Traefik Gateway API routing, Vault-backed self-signed Root CA trust injection, and Prometheus metrics scraping.

## Key Features

- **Service Health Monitoring**: Automated monitoring and status dashboard powered by Gatus, supporting HTTP, ICMP, DNS, TCP, and custom condition evaluations.
- **GitOps Endpoints Synchronization**: Built-in `git-sync` init container to clone and pull health check endpoint configurations from an external Git repository.
- **ConfigMap Endpoints**: Define custom endpoints directly in Helm values to be rendered into ConfigMaps for immediate monitoring.
- **Gateway API Routing**: Leverages Traefik and Kubernetes Gateway API's `HTTPRoute` with automatic HTTP-to-HTTPS redirection and secure TLS routing.
- **Root CA Trust Injection**: Automatically retrieve and mount custom self-signed Root CA certificates from HashiCorp Vault via External Secrets Operator to validate private Git repositories and internal endpoints.
- **Persistent Storage**: PersistentVolumeClaim backed SQLite database storage for status check history and retention.
- **Prometheus Metrics**: Built-in CoreOS `ServiceMonitor` for automated scraping of Gatus metrics.

## Getting Started

### Prerequisites

- A Kubernetes cluster (v1.24+)
- Helm 3.x installed
- [Gateway API](https://gateway-api.sigs.k8s.io/) CRDs and Traefik (or another compatible Gateway provider) installed
- [External Secrets Operator](https://external-secrets.io/) and access to a HashiCorp Vault instance (if `selfSingedRootCA.enabled` is `true`)
- [Prometheus Operator](https://prometheus-operator.dev/) installed (for `ServiceMonitor` metrics scraping)

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/stanislawhorna/helm-charts.git
   cd helm-charts
   ```

2. Configure your options in `charts/gatus/values.yaml` (or create a custom values file such as `prod-values.yaml`).

3. Install the chart:
   ```bash
   helm upgrade --install gatus ./charts/gatus \
     --namespace gatus \
     --create-namespace
   ```

## Repository Structure

- `charts/gatus/`: The primary chart directory.
  - `templates/`: Kubernetes manifests including deployment, service, configmaps, PVC, external-secrets, service-monitor, and gateway routing.
  - `values.yaml`: Main configuration settings.

## Configuration

The following table highlights the core configuration parameters.

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `gatusImage.repository` | Gatus container image repository | `twinproduction/gatus` |
| `gatusImage.tag` | Gatus container image tag | `v5.36.0` |
| `gitSyncImage.repository` | Git-sync container image repository | `k8s.gcr.io/git-sync/git-sync` |
| `gitSyncImage.tag` | Git-sync container image tag | `v3.6.3` |
| `endpointsSync.enabled` | Enable endpoints synchronization via Git-sync | `true` |
| `endpointsSync.gitRepo` | Remote Git repository URL containing endpoints | `https://github.com/your-username/gatus-endpoints.git` |
| `endpointsSync.gitBranch` | Git branch to sync endpoints from | `main` |
| `endpointsSync.gitInterval` | Interval in seconds between git sync checks | `60` |
| `endpoints` | List of local endpoint health check definitions | `[{name: Gatus, url: http://localhost:8080, ...}]` |
| `gateway.enabled` | Enable Kubernetes Gateway API `HTTPRoute` | `true` |
| `gateway.rootUrl` | Hostname/root URL for the Gatus dashboard | `https://gatus.example.com` |
| `gateway.gatewayName` | Name of the parent Gateway | `traefik-gateway` |
| `gateway.gatewayNamespace` | Namespace of the parent Gateway | `traefik` |
| `gateway.allowHttp` | Allow unencrypted HTTP traffic (disables redirect) | `false` |
| `persistence.enabled` | Enable persistent storage for SQLite data | `true` |
| `persistence.data.size` | Size of the data volume | `10Gi` |
| `persistence.data.storageClassName` | Storage class name for the data volume | `local-path-static` |
| `selfSingedRootCA.enabled` | Mount a custom self-signed Root CA cert for SSL/TLS verification | `true` |
| `selfSingedRootCA.ClusterSecretStoreName` | Name of the ClusterSecretStore for Root CA | `hcp-vault-secret-store` |
| `selfSingedRootCA.kvName` | Vault KV path for Root CA | `keyvault/self-signed-root-ca` |
| `selfSingedRootCA.certificateProperty` | Secret property containing the certificate | `certificate` |
| `resources.requests.cpu` | CPU request for the Gatus pod | `100m` |
| `resources.requests.memory` | Memory request for the Gatus pod | `256Mi` |
| `resources.limits.cpu` | CPU limit for the Gatus pod | `500m` |
| `resources.limits.memory` | Memory limit for the Gatus pod | `512Mi` |
