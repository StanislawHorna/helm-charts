{{/*
Default Mimir Configuration
*/}}
{{- define "lgtm-stack.MimirDefaultConfig" -}}
target: all,overrides-exporter

server:
  log_level: {{ default "info" .Values.mimir.logLevel }}
  log_format: json
  
limits:
  ingestion_rate: 100000
  ingestion_burst_size: 1000000
  max_global_series_per_user: 0 # unlimited
  max_query_parallelism: 64
  out_of_order_time_window: 10m


# Configure Mimir to use Minio as object storage backend.
common:
  storage:
  {{ if .Values.mimir.longTermStorage.enabled}}
    backend: s3
    s3:
      endpoint: {{ .Values.mimir.longTermStorage.s3Endpoint }}
      access_key_id: ${S3_ACCESS_KEY}
      secret_access_key: ${S3_SECRET_KEY}
      insecure: {{ .Values.mimir.longTermStorage.s3Insecure }}
      bucket_name: {{ .Values.mimir.longTermStorage.s3Bucket}}
  {{ else }}
    backend: filesystem
    filesystem:
      dir: /data/mimir-storage
  {{ end }}
blocks_storage:
  storage_prefix: blocks
  tsdb:
    dir: /data/ingester
    block_ranges_period: ["2h"]

      
  # --- Caching Configuration (Memcached sidecar) ---
  bucket_store:
  {{ if .Values.mimir.longTermStorage.enabled }}
    sync_dir: /data/store-gateway
  {{ end }}
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
  log_queries_longer_than: 10s
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

{{- end -}}