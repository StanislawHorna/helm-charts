{{/*
Default Mimir Configuration
*/}}
{{- define "lgtm-stack.MimirDefaultConfig" -}}
# target: all runs Mimir in "single-binary" mode (all components in one process).
# overrides-exporter exposes per-tenant limit overrides as Prometheus metrics.
target: all,overrides-exporter

server:
  log_level: {{ default "info" .Values.mimir.logLevel }}
  log_format: json
  
limits:
  # WHAT: Caps the number of samples per second the ingester will accept.
  # WHY: Set to 100k to allow a high volume of metrics without throttling.
  ingestion_rate: 100000
  
  # WHAT: Allows temporary spikes in ingestion traffic up to 1M.
  # WHY: Prevents dropped metrics during sudden bursts (e.g., after a network partition resolves).
  ingestion_burst_size: 1000000
  
  # WHAT: Maximum number of active time series a single tenant can send.
  # WHY: Set to 0 (unlimited) and don't hit artificial ceilings in a trusted environment.
  max_global_series_per_user: 0 
  
  # WHAT: The maximum number of parallel workers that can execute a single query.
  # WHY: Set to 128 for high performance. This allows Mimir to heavily parallelize complex queries across data.
  max_query_parallelism: 128
  
  # WHAT: The time window during which Mimir will accept metrics with older timestamps than the most recently received one.
  # WHY: 10m is standard to accommodate slight clock drifts or delays in Prometheus/Agent sending data.
  out_of_order_time_window: 10m
  
  {{ if .Values.mimir.longTermStorage.enabled}}
  # WHAT: Instructs the Querier to check the local Ingester (RAM/Disk) for data up to retention specified in values.yaml + 24h.
  # WHY: Matches `retention_period`. It guarantees Mimir will find the recent data locally.
  query_ingesters_within: {{ include "lgtm-stack.add24h" (include "lgtm-stack.retentionHours" .Values.mimir.longTermStorage.localCacheRetention) }}
  {{ end }}
  
  # WHAT: Snaps query start/end times to a standard time grid (e.g., exactly on the minute).
  # WHY: Dramatically increases the likelihood that two identical queries from different users hit the Memcached results cache.
  align_queries_with_step: true


# Configure Mimir to use S3 as the object storage backend for long-term historical data.
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
    # Fallback to local disk if S3 is disabled.
    backend: filesystem
    filesystem:
      dir: {{ include "lgtm-stack.Mimir.DefaultLocalPath" . }}/mimir-storage
  {{ end }}

blocks_storage:
  storage_prefix: blocks
  tsdb:
    dir: {{ include "lgtm-stack.Mimir.DefaultLocalPath" . }}/ingester
    {{ if .Values.mimir.longTermStorage.enabled}}
    # WHAT: The time span of a single TSDB block before it is "cut", finalized, and shipped to S3.
    # WHY: Set to 1h to ensure a strict 1-hour Recovery Point Objective (RPO) in case of catastrophic pod failure.
    block_ranges_period: ["1h"]
    
    # WHAT: How long the finalized blocks stay on the local disk of the Ingester.
    # WHY: This acts as a massive local cache, making queries for recent data lightning fast because they don't require S3 network calls.
    retention_period: {{ include "lgtm-stack.add24h" (include "lgtm-stack.retentionHours" .Values.mimir.longTermStorage.localCacheRetention) }}
    {{ end }}
      
  # --- Caching Configuration (Memcached sidecar) ---
  # These caches drastically reduce S3 API calls and CPU load.
  bucket_store:
  {{ if .Values.mimir.longTermStorage.enabled }}
    # WHERE: Local directory for the Store-Gateway to keep S3 block indexes.
    sync_dir: {{ include "lgtm-stack.Mimir.DefaultLocalPath" . }}/store-gateway
  {{ end }}
  
    # WHAT: Caches the actual compressed metric data chunks fetched from S3.
    chunks_cache:
      {{ include "lgtm-stack.MimirConfig.Memcached" . | indent 6 }}

    # WHAT: Caches the index files used to look up which chunks contain specific labels.
    index_cache:
      {{ include "lgtm-stack.MimirConfig.Memcached" . | indent 6 }}

    # WHAT: Caches tenant metadata and label sets.
    metadata_cache: 
      {{ include "lgtm-stack.MimirConfig.Memcached" . | indent 6 }}

# Configure the Query Frontend to use the Results Cache
frontend:
  {{ if .Values.mimir.longTermStorage.enabled }}
  # WHAT: Breaks large user queries (e.g., "give me 30 days of data") into smaller sub-queries of this size.
  # WHY: 24h means a 30-day query becomes 30 parallel 1-day queries. (Note: Setting this to 1h is usually better for utilizing all 128 parallel workers).
  split_queries_by_interval: 24h
  {{ end }}
  
  # WHAT: Logs any query that takes longer than 10 seconds for troubleshooting.
  log_queries_longer_than: 10s
  
  # WHAT: Caches the final, fully-evaluated results of queries.
  cache_results: true
  results_cache:
    {{- include "lgtm-stack.MimirConfig.Memcached" . | indent 4}}

querier:

  {{ if .Values.mimir.longTermStorage.enabled}}
  # WHAT: Tells the querier to ONLY fetch data from S3 (Store-Gateway) if the requested data is older than 8 days.
  # WHY: Works with your 9-day local retention to ensure the querier relies entirely on fast local disk for the last 8-9 days of metrics.
  query_store_after: {{ include "lgtm-stack.retentionHours" .Values.mimir.longTermStorage.localCacheRetention }}
  {{ end }}
  
  # WHAT: The maximum number of concurrent sub-queries a single Querier worker will process.
  # WHY: 16 prevents a single complex query from causing out-of-memory (OOM) crashes on the worker.
  max_concurrent: 16

query_scheduler:
  # WHAT: Limits the maximum number of queries a single tenant can queue up at once.
  # WHY: 2048 prevents a rogue script or heavy dashboard refresh from locking up the entire Mimir query system.
  max_outstanding_requests_per_tenant: 2048

ingester:
  ring:
    # WHAT: The number of Ingesters that will store a copy of an incoming metric.
    # WHY: Set to 1 because this is a single-binary setup. High Availability (HA) setups usually use 3.
    replication_factor: 1

compactor:
  # WHERE: Local directory for the compactor to download and merge blocks.
  data_dir: {{ include "lgtm-stack.Mimir.DefaultLocalPath" . }}/compactor
  
  {{ if .Values.mimir.longTermStorage.enabled}}
  # WHAT: The progression of block sizes the compactor creates over time.
  # WHY: It takes your custom 1h blocks, merges two into a 2h block, then four 2h blocks into an 8h block, etc. This optimizes S3 storage and long-term query speed.
  block_ranges: ["1h", "2h", "8h", "48h"]
  {{ end }}

{{- end -}}

{{ define "lgtm-stack.MimirConfig.Memcached" }}
backend: memcached
memcached:
  addresses: 127.0.0.1:11211
  timeout: 500ms
  # WHY: Set to 128 to ensure the connection pool matches your max_query_parallelism (128), preventing bottleneck queues.
  max_idle_connections: 128
{{ end }}