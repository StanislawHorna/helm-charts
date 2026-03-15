# lgtm-stack-single-node

The **LGTM Stack** (Loki, Grafana, Tempo, Mimir) plus **Alloy**, optimized for single-node Kubernetes clusters. This chart is designed for development environments, small VPS setups, or edge deployments where resource efficiency is key.

## Included Components:

- **Grafana**: Visualization and dashboarding.
- **Loki**: Log aggregation and storage.
- **Mimir**: Long-term metrics storage (Prometheus-compatible).
- **Tempo**: Distributed tracing backend.
- **Alloy**: Unified collector for logs, metrics, and traces.
- **Support Components**:
  - `kube-state-metrics`: Cluster-level metrics.
  - `prometheus-node-exporter`: Hardware and OS metrics.
  - `crds`: Automated management of Prometheus Operator CRDs.

## Getting Started

### Prerequisites

- A Kubernetes cluster (v1.24+)
- Helm 3.x installed
- (Optional) `cert-manager` and `gateway-api` if using the built-in Grafana Gateway configuration.

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/stanislawhorna/observability-helm-charts.git
   cd observability-helm-charts
   ```

2. Update dependencies for the chart:

   ```bash
   helm dependency update lgtm-stack-single-node
   ```

3. Install the chart:
   ```bash
   helm install lgtm-stack ./lgtm-stack-single-node --namespace observability --create-namespace
   ```

## Repository Structure

- `lgtm-stack-single-node/`: The primary chart for the LGTM stack.
  - `charts/crds/`: A subchart to manage necessary CRDs.
  - `files/grafana-dashboards/`: Pre-configured JSON dashboards (e.g., Kubernetes resource consumption).
  - `templates/`: Modular templates for each LGTM component.
