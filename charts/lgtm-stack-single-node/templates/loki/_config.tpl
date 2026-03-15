{{/*
Default Loki Configuration
*/}}
{{- define "lgtm-stack.LokiDefaultConfig" -}}
auth_enabled: false

server:
  http_listen_port: 3100
  http_path_prefix: /
  log_format: json

common:
  path_prefix: /data/loki
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory
  storage:
    filesystem:
      chunks_directory: /data/loki/chunks
      rules_directory: /data/loki/rules

schema_config:
  configs:
    - from: 2025-09-18
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: tsdb_index_
        period: 24h

ingester:
  chunk_idle_period: 60s
  chunk_retain_period: 60s
  wal:
    enabled: true
    dir: /data/loki/wal

query_range:
  results_cache:
    cache:
      memcached_client:
        consistent_hash: true
        addresses: "127.0.0.1:11211"
        timeout: 500ms
        update_interval: 1m

chunk_store_config:
  chunk_cache_config:
    memcached_client:
      consistent_hash: true
      addresses: "127.0.0.1:11211"

limits_config:
  retention_period: 365d
  ingestion_rate_mb: 10
  ingestion_burst_size_mb: 20
  max_streams_per_user: 5000
  max_entries_limit_per_query: 10000
  max_query_parallelism: 32
  max_query_series: 50000

compactor:
  working_directory: /data/loki/retention
  retention_enabled: true
  retention_delete_delay: 24h
  delete_request_store: filesystem

analytics:
  reporting_enabled: false
{{- end -}}
