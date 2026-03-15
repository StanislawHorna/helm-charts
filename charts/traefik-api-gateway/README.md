# traefik-api-gateway

A Helm chart for the **Traefik API Gateway**, leveraging the modern **Kubernetes Gateway API** for cloud-native traffic management. This chart is designed to provide a production-ready entry point with automated TLS management.

## Included Components:

- **Traefik**: The cloud-native ingress controller and load balancer.
- **Gateway API CRDs**: Comprehensive v1.2.1 (experimental) Custom Resource Definitions for `Gateway`, `HTTPRoute`, `TCPRoute`, `UDPRoute`, etc.
- **TLS Management**: Seamless integration with `cert-manager` for automated certificate issuance and rotation.

## Getting Started

### Prerequisites

- A Kubernetes cluster (v1.24+)
- Helm 3.x installed
- `cert-manager` installed in the cluster (for HTTPS support)

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/stanislawhorna/helm-charts.git
   cd helm-charts
   ```

2. Update dependencies for the chart:

   ```bash
   helm dependency update ./charts/traefik-api-gateway
   ```

3. Install the chart:
   ```bash
   helm upgrade --install traefik-gateway ./charts/traefik-api-gateway \
     --namespace traefik \
     --create-namespace
   ```

## Repository Structure

- `traefik-api-gateway/`: The primary chart for the Traefik Gateway.
  - `crds/`: Standard and experimental Gateway API CRDs.
  - `templates/`: Modular templates for the Gateway, TLS Certificates, and more.
  - `values.yaml`: Configuration for hostname suffixes, issuers, and Traefik port mapping.

## Configuration

The chart uses a main configuration block `traefikApiGateway` and passes other values directly to the official Traefik subchart.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `traefikApiGateway.enabled` | Enable the Gateway resource | `true` |
| `traefikApiGateway.https.enabled` | Enable HTTPS listener and Certificate | `true` |
| `traefikApiGateway.https.certificate.hostnameSuffix` | Main hostname and wildcard suffix | `example.com` |
| `traefikApiGateway.https.certificate.certIssuer.name` | `cert-manager` Issuer or ClusterIssuer name | `vault-issuer` |
| `traefikApiGateway.https.certificate.certIssuer.kind` | `cert-manager` issuer kind | `ClusterIssuer` |
