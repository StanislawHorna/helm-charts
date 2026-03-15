# ☸️ Helm Charts

[![Release Charts](https://github.com/StanislawHorna/helm-charts/actions/workflows/release.yaml/badge.svg)](https://github.com/StanislawHorna/helm-charts/actions/workflows/release.yaml)

A collection of curated Helm charts for deploying high-performance stacks on Kubernetes, with a focus on efficiency, observability, and modern cloud-native standards.

---

## 🚀 Available Charts

Explore our collection of production-ready charts.

| Chart                                                           | Description                                                                                                                                                  | Links                                                                                              |
| :-------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------- |
| **[`lgtm-stack-single-node`](./charts/lgtm-stack-single-node)** | The complete **LGTM Stack** (Loki, Grafana, Tempo, Mimir) + Alloy. Optimized for resource-constrained environments like single-node clusters or edge setups. | [Details](./charts/lgtm-stack-single-node) • [Values](./charts/lgtm-stack-single-node/values.yaml) |
| **[`traefik-api-gateway`](./charts/traefik-api-gateway)**       | Modern **Traefik API Gateway** implementation leveraging the **Kubernetes Gateway API**. Includes automated TLS management with cert-manager.                | [Details](./charts/traefik-api-gateway) • [Values](./charts/traefik-api-gateway/values.yaml)       |

---

## 🛠️ Getting Started

### 1. Add Repository

To start using these charts, add the repository to Helm:

```bash
helm repo add sh-helm-charts https://StanislawHorna.github.io/helm-charts
helm repo update
```

### 2. Install a Chart

Install any chart from the repository using the following command:

```bash
# Example: Installing the LGTM Stack
helm install my-lgtm sh-helm-charts/lgtm-stack-single-node --namespace observability --create-namespace
```

---

## 🧩 Key Features

- **Efficiency First**: Optimized configurations for minimal resource overhead.
- **Observability Built-in**: Deep integration with Grafana and Prometheus-compatible metrics.
- **Modern Standards**: Support for Kubernetes Gateway API and cloud-native practices.
- **Automated CI/CD**: Charts are linted and released automatically via GitHub Actions.
