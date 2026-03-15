{{/*
Default Mimir Configuration
*/}}
{{- define "lgtm-stack.MimirDefaultConfig" -}}
target: all,overrides-exporter

limits:
  ingestion_rate: 100000
  ingestion_burst_size: 1000000
  max_global_series_per_user: 0 # unlimited

# Configure Mimir to use Minio as object storage backend.
common:
  storage:
    backend: filesystem
    filesystem:
      dir: /data/mimir-storage

# Blocks storage requires a prefix when using a common object storage bucket.
blocks_storage:
  storage_prefix: blocks
  tsdb:
    dir: /data/ingester

  # --- Caching Configuration (Memcached sidecar) ---
  bucket_store:
    chunks_cache:
      backend: memcached
      memcached:
        addresses: 127.0.0.1:11211

    index_cache:
      backend: memcached
      memcached:
        addresses: 127.0.0.1:11211

    metadata_cache:
      backend: memcached
      memcached:
        addresses: 127.0.0.1:11211

# Configure the Query Frontend to use the Results Cache
frontend:
  cache_results: true
  results_cache:
    backend: memcached
    memcached:
      addresses: 127.0.0.1:11211

ingester:
  ring:
    replication_factor: 1

compactor:
  data_dir: /data/compactor

server:
  log_level: info
  log_format: json

{{- end -}}
