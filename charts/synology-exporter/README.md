# synology-exporter

A Helm chart for deploying the Synology NAS exporter to collect hardware, storage pool, disk, and UPS metrics for Prometheus via SNMP. This chart supports multi-device monitoring, secure SNMP v3 configurations, and integrates with **External Secrets Operator** for credential synchronization.

## Key Features

- **SNMP v3 Support**: Configured for secure SNMP v3 authentication and encryption (defaults to `authPriv` with SHA/DES).
- **Multi-Device Support**: Easily monitor multiple Synology NAS devices using distinct hostnames or IPs.
- **External Secrets Support**: Dynamically retrieve SNMP v3 authentication credentials (username, auth password, priv password) from HashiCorp Vault.
- **ServiceMonitor Support**: Pre-configured `ServiceMonitor` resource for automated scraping by the Prometheus Operator.
- **Resource Optimized**: Tailored resource requests and limits suited for SNMP polling operations.

## Getting Started

### Prerequisites

- A Kubernetes cluster (v1.24+)
- Helm 3.x installed
- SNMP enabled on target Synology NAS devices (with SNMP v3 user credentials configured)
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
   helm upgrade --install synology-exporter ./charts/synology-exporter \
     --namespace monitoring \
     --create-namespace
   ```

## Repository Structure

- `charts/synology-exporter/`: The primary chart directory.
  - `files/`: Contains the SNMP configuration profile (`snmp_auths_dsm_snmp3.yml`) and MIB-derived module file (`snmp_modules_synology.yml`).
  - `templates/`: Kubernetes manifests including deployment, service, service-monitor, and external-secret.
  - `values.yaml`: Main configuration settings.

## Configuration

The following table highlights the core configuration parameters.

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `image.tag` | The container image tag | `v0.29.0` |
| `resources.requests.cpu` | CPU request limit | `50m` |
| `resources.requests.memory` | Memory request limit | `32Mi` |
| `resources.limits.cpu` | CPU limit | `100m` |
| `resources.limits.memory` | Memory limit | `64Mi` |
| `externalSecret.enabled` | Enable External Secrets resource generation | `true` |
| `externalSecret.ClusterSecretStoreName` | Target ClusterSecretStore name | `hcp-vault-secret-store` |
| `externalSecret.kvName` | Key-value store path in Vault for default credentials | `synology-credentials` |
| `defaultSnmpSettings.version` | SNMP version to use | `3` |
| `defaultSnmpSettings.security_level` | SNMP security level | `authPriv` |
| `defaultSnmpSettings.auth_protocol` | SNMP authentication protocol | `SHA` |
| `defaultSnmpSettings.priv_protocol` | SNMP privacy/encryption protocol | `DES` |
| `synologyDevices` | List of Synology devices to monitor (names, IPs, and Vault references) | See `values.yaml` |
