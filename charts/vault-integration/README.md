# vault-integration

A Helm chart for integrating **HashiCorp Vault** with Kubernetes, providing automated certificate management via **cert-manager** and secret synchronization via **External Secrets Operator**. This chart simplifies the setup of a secure, Vault-backed identity and secret management layer within your cluster.

## Included Components:

- **cert-manager**: Automated management and issuance of TLS certificates.
  - Deploys `controller`, `cainjector`, and `webhook` (v1.20.0).
  - Bundled with necessary Custom Resource Definitions (CRDs).
- **External Secrets Operator**: Seamlessly syncs secrets from Vault into Kubernetes Secrets (installed as a subchart dependency).
- **Vault Integration Resources**:
  - `ClusterIssuer`: Pre-configured to use Vault's PKI engine for automated certificate signing.
  - `ClusterSecretStore`: Configures cluster-wide access to Vault's KV (Key-Value) engines.

## Getting Started

### Prerequisites

- A Kubernetes cluster (v1.24+)
- Helm 3.x installed
- A running **HashiCorp Vault** instance accessible from the cluster.
- Vault **AppRole** authentication enabled and configured (recommended).

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/stanislawhorna/helm-charts.git
   cd helm-charts
   ```

2. Update dependencies for the chart:

   ```bash
   helm dependency update ./charts/vault-integration
   ```

3. Install the chart:
   ```bash
   helm upgrade --install vault-integration ./charts/vault-integration \
     --namespace vault-integration \
     --create-namespace
   ```

## Repository Structure

- `vault-integration/`: The primary chart directory.
  - `crds/`: Cert-manager CRDs for simplified lifecycle management.
  - `templates/`: Modular templates for cert-manager deployments, RBAC, and Vault-specific resources.
  - `values.yaml`: Main configuration file for Vault connectivity and component resource limits.

## Configuration

The following table highlights the core configuration parameters for connecting to Vault.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `vaultAccess.server` | The URL of the Vault server | `http://<vault-ip-address>:8200` |
| `vaultAccess.auth.appRole.enabled` | Enable AppRole authentication | `true` |
| `vaultAccess.auth.appRole.roleId` | The RoleID for the Vault AppRole | `<to-be-replaced>` |
| `SecretStore` | List of ClusterSecretStore configurations for KV engines | See `values.yaml` |
| `certManager.clusterIssuer.name` | Name of the Vault-backed ClusterIssuer | `vault-issuer` |
| `certManager.clusterIssuer.path` | The path to the PKI sign endpoint in Vault | `pki/sign/<domain>` |
