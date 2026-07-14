# omada-exporter

A Helm chart for deploying the TP-Link Omada exporter to collect performance and client metrics for Prometheus. This chart also integrates with **Grafana Loki** for logs and **External Secrets Operator** for secure credentials synchronization.

## Key Features

- **Loki Logging Integration**: Forward application logs directly to a Loki instance with configurable timezone and log level settings.
- **External Secrets Support**: Out-of-the-box support for generating Kubernetes Secrets from sensitive credentials stored in HashiCorp Vault via the External Secrets Operator.
- **ServiceMonitor Support**: Pre-configured `ServiceMonitor` resource for automated scraping by the Prometheus Operator.
- **Resource Efficient**: Low footprint configuration with tailored resource requests and limits.

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
   helm upgrade --install omada-exporter ./charts/omada-exporter \
     --namespace monitoring \
     --create-namespace
   ```

## Repository Structure

- `charts/omada-exporter/`: The primary chart directory.
  - `templates/`: Kubernetes manifests including deployment, service, service-monitor, and external-secret.
  - `values.yaml`: Main configuration settings.

## Configuration

The following table highlights the core configuration parameters.

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `image.tag` | The container image tag | `26.19.0` |
| `resources.requests.cpu` | CPU request limit | `20m` |
| `resources.requests.memory` | Memory request limit | `16Mi` |
| `resources.limits.cpu` | CPU limit | `100m` |
| `resources.limits.memory` | Memory limit | `64Mi` |
| `loki.url` | Endpoint URL for Loki logs | `http://loki-svc.lgtm-stack.svc.cluster.local:3100` |
| `loki.logLevel` | Log level for the exporter | `info` |
| `externalSecret.enabled` | Enable External Secrets resource generation | `true` |
| `externalSecret.ClusterSecretStoreName` | Target ClusterSecretStore name | `hcp-vault-secret-store` |
| `externalSecret.kvName` | Key-value store path in Vault for credentials | `omada-controller-credentials` |
| `omada.controllerUrl` | URL to access the Omada Controller | `http://192.168.0.100:8088` |
| `omada.controllerName` | Label for the Omada Controller name | `Omada` |
