# external-metrics-scrape

A Helm chart for scraping external metrics from non-Kubernetes targets using Prometheus Operator's `ServiceMonitor` resources. It creates a headless Kubernetes Service, a corresponding `EndpointSlice` mapped to the external device's IP, and a `ServiceMonitor` targeting the service.

## Key Features

- **External Target Mapping**: Seamlessly register external, off-cluster devices (like Home Assistant, smart routers, or other physical/virtual servers) inside Kubernetes.
- **Dynamic Configuration**: Support multiple external targets, each with its own scrape interval, metrics path, scheme, IP, and port.
- **ServiceMonitor Integration**: Built-in compatibility with Prometheus Operator using configurable labels to ensure auto-discovery.
- **Resource Efficient**: Extremely lightweight since it only declares virtual/headless Kubernetes resources without running any pods/containers.

## Getting Started

### Prerequisites

- A Kubernetes cluster (v1.24+)
- Helm 3.x installed
- Prometheus Operator or `kube-prometheus-stack` installed in the cluster (to utilize `ServiceMonitor` resources)

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/stanislawhorna/helm-charts.git
   cd helm-charts
   ```

2. Install the chart:
   ```bash
   helm upgrade --install external-metrics-scrape ./charts/external-metrics-scrape \
     --namespace monitoring \
     --create-namespace
   ```

## Repository Structure

- `charts/external-metrics-scrape/`: The primary chart directory.
  - `templates/`: Kubernetes manifests including service, endpoints, and service-monitor.
  - `values.yaml`: Main configuration settings.

## Configuration

The following table highlights the core configuration parameters.

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `serviceMonitorLabels` | Labels applied to the generated ServiceMonitors for Prometheus Operator discovery | `release: prometheus` |
| `scrapeConfigs` | List of external scrape targets (names, intervals, paths, schemes, IPs, and ports) | See `values.yaml` |

### Configuration Example

Below is an example of defining multiple external scrape targets in your `values.yaml`:

```yaml
serviceMonitorLabels:
  release: prometheus

scrapeConfigs:
  - name: home-assistant
    scrape_interval: 15s
    path: /api/prometheus
    scheme: http
    ip: 192.168.1.100
    port: 8123
  - name: smart-router
    scrape_interval: 30s
    path: /metrics
    scheme: http
    ip: 192.168.1.1
    port: 9100
```
