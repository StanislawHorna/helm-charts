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
    backend: s3
    s3:
      endpoint: rust-fs.internal-s3.svc.cluster.local:9000
      access_key_id: ${S3_ACCESS_KEY}
      secret_access_key: ${S3_SECRET_KEY}
      insecure: {{ .Values.mimir.longTermStorage.s3Insecure }}
      bucket_name: "mimir-data"
  
# Blocks storage requires a prefix when using a common object storage bucket.
blocks_storage:
  storage_prefix: blocks
  tsdb:
    dir: /data/ingester
    block_ranges_period: ["2h"]

      
  # --- Caching Configuration (Memcached sidecar) ---
  bucket_store:
    sync_dir: /data/store-gateway
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

query_scheduler:
  max_outstanding_requests_per_tenant: 2048

ingester:
  ring:
    replication_factor: 1

compactor:
  data_dir: /data/compactor

server:
  log_level: info
  log_format: json

{{- end -}}