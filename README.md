# Helm Charts

A collection of Helm charts for deploying useful stacks on Kubernetes, with a focus on efficiency and ease of use.

## Available Charts

### [lgtm-stack-single-node](./lgtm-stack-single-node)

The **LGTM Stack** (Loki, Grafana, Tempo, Mimir) plus **Alloy**, optimized for single-node Kubernetes clusters. This chart is designed for development environments, small VPS setups, or edge deployments where resource efficiency is key.

### [traefik-api-gateway](./traefik-api-gateway)

The **Traefik API Gateway**, leveraging the modern **Kubernetes Gateway API** for cloud-native traffic management. This chart is designed to provide a production-ready entry point with automated TLS management.

## Getting Started

### Prerequisites

- Helm 3.x installed

### Installation

1. Add repository

```shell
helm repo add sh-helm-charts https://StanislawHorna.github.io/helm-charts
```

2. Update index

```shell
helm repo update
```

3. Install chart

```shell
helm install <your-release-name> sh-helm-charts/<chart-name>
```

- `<chart-name>` - represents directory name of helm chart in [`/charts`](/charts/)
