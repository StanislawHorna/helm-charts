{{/*
Default Tempo Configuration
*/}}
{{- define "lgtm-stack.TempoDefaultConfig" -}}
server:
  http_listen_port: 3200
  grpc_listen_port: 9095

# Data ingestion receivers
distributor:
  receivers:
    jaeger:
      protocols:
        grpc:
        thrift_compact:
        thrift_binary:
        thrift_http:
    zipkin:
    opencensus:
    otlp:
      protocols:
        grpc:
        http:

compactor:
  compaction:
    block_retention: 336h # 14 days

storage:
  trace:
    backend: local
    local:
      path: /data/tempo/traces

    wal:
      path: /data/tempo/wal

cache:
  caches:
    - roles:
        - bloom
        - parquet-footer
        - parquet-page
        - frontend-search

      memcached:
        addresses: 127.0.0.1:11211

metrics_generator:
  registry:
    external_labels:
      source: tempo
      cluster: "{{ .Release.Name }}"
  storage:
    path: /data/tempo/generator/wal
    remote_write:
      - url: http://{{ include "lgtm-stack.componentSVC" "mimir" }}:8080/api/v1/push
        send_exemplars: true
        headers:
          "X-Scope-OrgID": "{{ .Release.Name }}"
  traces_storage:
    path: /data/tempo/generator/traces

{{- end -}}
