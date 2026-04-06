# Storage Classes

A Helm chart for provisioning dynamic storage solutions on Kubernetes. This chart facilitates the deployment of the **Rancher Local Path Provisioner** for node-local storage and the **NFS CSI Driver** for shared network storage.

## Key Features

- **Local Storage**: Lightweight dynamic provisioning using the node's local filesystem (via Rancher Local Path Provisioner).
- **Shared Storage**: Modern NFS support leveraging the standard **NFS CSI Driver**.
- **k0s Optimized**: Pre-configured to handle the non-standard paths used by the k0s distribution.
- **Resource Efficient**: Minimal overhead, ideal for single-node or edge environments.

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/stanislawhorna/helm-charts.git
   cd helm-charts
   ```

2. Update dependencies for the chart:

   ```bash
   helm dependency update ./charts/storage-classes
   ```

3. Install the chart:
   ```bash
   helm upgrade --install storage-classes ./charts/storage-classes \
     --namespace storage \
     --create-namespace
   ```

## Configuration

### Local Path Provisioner
The Local Path Provisioner is embedded within this chart. It is useful for high-performance, node-local volumes.

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `localPath.storageClassName` | Name of the created StorageClass | `local-storage` |
| `localPath.reclaimPolicy` | PVC reclaim policy | `Delete` |
| `localPath.volumeBindingMode` | When to bind the volume | `WaitForFirstConsumer` |

### NFS CSI Driver
The NFS CSI Driver is included as a sub-chart dependency.

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `csi-driver-nfs.enabled` | Enable the NFS CSI Driver | `false` |
| `csi-driver-nfs.kubeletDir` | Path to the host's kubelet directory | `/var/lib/k0s/kubelet` |
| `csi-driver-nfs.storageClass.name` | Name of the NFS StorageClass | `nfs-storage` |
| `csi-driver-nfs.storageClass.parameters.server` | NFS Server IP or Hostname | `<nfs-server-ip>` |
| `csi-driver-nfs.storageClass.parameters.share` | Path on the NFS server | `/<directory>/<path>` |
