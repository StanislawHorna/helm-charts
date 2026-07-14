# pve-exporter

A Helm chart for deploying the Proxmox VE (PVE) exporter to collect cluster, node, and VM/container metrics for Prometheus. This chart supports multi-server configurations and integrates with **External Secrets Operator** for secure credentials synchronization.

## Key Features

- **Multi-Server Support**: Monitor multiple Proxmox VE servers or clusters from a single deployment.
- **External Secrets Support**: Fetch PVE API credentials (username, token name, token value) dynamically from HashiCorp Vault.
- **ServiceMonitor Support**: Pre-configured `ServiceMonitor` resource for automated scraping by the Prometheus Operator.
- **SSL Control**: Easily toggle SSL verification for environments using self-signed Proxmox VE certificates.
- **Resource Optimized**: Tailored resource requests and limits suited for continuous exporters.

## Getting Started

### Prerequisites

- A Kubernetes cluster (v1.24+)
- Helm 3.x installed
- (Optional) Prometheus Operator / kube-prometheus-stack for ServiceMonitor scraping
- (Optional) External Secrets Operator & HashiCorp Vault for credentials integration

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/stanislawhorna/helm-charts.git
   cd helm-charts
   ```

2. Install the chart:
   ```bash
   helm upgrade --install pve-exporter ./charts/pve-exporter \
     --namespace monitoring \
     --create-namespace
   ```

## Repository Structure

- `charts/pve-exporter/`: The primary chart directory.
  - `templates/`: Kubernetes manifests including deployment, configmap, service, service-monitor, and external-secret.
  - `values.yaml`: Main configuration settings.

## Configuration

The following table highlights the core configuration parameters.

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `image.tag` | The container image tag | `3.5.5` |
| `resources.requests.cpu` | CPU request limit | `50m` |
| `resources.requests.memory` | Memory request limit | `32Mi` |
| `resources.limits.cpu` | CPU limit | `100m` |
| `resources.limits.memory` | Memory limit | `64Mi` |
| `externalSecret.enabled` | Enable External Secrets resource generation | `true` |
| `externalSecret.ClusterSecretStoreName` | Target ClusterSecretStore name | `hcp-vault-secret-store` |
| `externalSecret.kvName` | Key-value store path in Vault for credentials | `pve-cluster-credentials` |
| `externalSecret.verifySsl` | Toggle SSL verification for PVE api connections | `false` |
| `pveServers` | List of PVE servers to scrape (names, IPs, and local Vault KV secret references) | See `values.yaml` |
