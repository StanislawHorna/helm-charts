# rust-fs

A Helm chart for deploying **rust-FS**, a lightweight and high-performance file storage application. This chart is designed to work seamlessly with the **Kubernetes Gateway API** and provides built-in integration for observability via **Grafana Alloy**.

## Key Features

- **High-Performance Storage**: Optimized for low-latency file operations with configurable resource limits.
- **Automated Secret Management**: Automatically generates secure 16-character access and secret keys if they don't already exist, ensuring idempotent deployments.
- **Gateway API Integration**: Pre-configured `HTTPRoute` resources for both the API (`:9000`) and the management console (`:9001`), compatible with modern gateways like Traefik.
- **Observability Ready**: Built-in support for OTLP log and metric forwarding to a Grafana Alloy instance.
- **Shared Storage**: Configured for `ReadWriteMany` access modes, making it ideal for shared storage environments (e.g., NFS).

## Getting Started

### Prerequisites

- A Kubernetes cluster (v1.24+)
- Helm 3.x installed
- (Optional) A Gateway API controller (like `traefik-api-gateway`) if using built-in ingress routing.
- (Optional) An NFS or similar StorageClass that supports `ReadWriteMany`.

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/stanislawhorna/helm-charts.git
   cd helm-charts
   ```

2. Install the chart:
   ```bash
   helm upgrade --install rust-fs ./charts/rust-fs \
     --namespace rust-fs \
     --create-namespace
   ```

## Configuration

The following table highlights the core configuration parameters.

| Parameter                        | Description                                | Default                    |
| -------------------------------- | ------------------------------------------ | -------------------------- |
| `rustFS.image.tag`               | The container image tag                    | `1.0.0-alpha.90`           |
| `rustFS.serverDomains`           | Allowed server domains for the application | `example.com`              |
| `rustFS.alloyAddress`            | Endpoint for OTLP observability data       | `http://alloy-svc...:4318` |
| `rustFS.gateway.enabled`         | Enable HTTPRoute resources                 | `true`                     |
| `rustFS.gateway.apiHostname`     | External hostname for the API              | `api.example.com`          |
| `rustFS.gateway.consoleHostname` | External hostname for the Console          | `console.example.com`      |
| `rustFS.storage.size`            | Size of the persistent volume              | `200Gi`                    |
| `rustFS.storage.storageClass`    | StorageClass to use for persistence        | `nfs-storage-static`       |
