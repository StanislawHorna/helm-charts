{{/*
Default Alloy HCL Configuration
*/}}
{{- define "lgtm-stack.alloyDefaultConfig" -}}
logging {
  level  = "info"
  format = "json"
}

loki.write "default" {
  endpoint {
    url = "http://{{ include "lgtm-stack.componentSVC" "loki" }}:3100/loki/api/v1/push"
  }
}


// Discover Pods on the current Node (critical for DaemonSet efficiency)
discovery.kubernetes "pod" {
  role = "pod"
  
  // Restrict to pods on the node to reduce cpu & memory usage
  selectors {
    role = "pod"
    field = "spec.nodeName=" + coalesce(sys.env("HOSTNAME"), constants.hostname)
  }
}

// Relabel the discovered targets and add standard Loki labels
discovery.relabel "kube_relabel" {
  targets = discovery.kubernetes.pod.targets

  // Map namespace
  rule {
    source_labels = ["__meta_kubernetes_namespace"]
    target_label  = "namespace"
  }

  // Map pod name
  rule {
    source_labels = ["__meta_kubernetes_pod_name"]
    target_label  = "pod"
  }

  // Map container name
  rule {
    source_labels = ["__meta_kubernetes_container_name"]
    target_label  = "container"
  }
}

// Collect logs from the discovered and relabeled pods
loki.source.kubernetes "container_logs" {
  targets    = discovery.relabel.kube_relabel.output
  forward_to = [loki.write.default.receiver]
}

// Collect Kubernetes API Events
loki.source.kubernetes_events "events" {
  forward_to = [loki.write.default.receiver]
  job_name   = "kubernetes-events"
  log_format = "json"
}

// --- Metrics Discovery via ServiceMonitors ---

// Discover ServiceMonitors in the cluster
prometheus.operator.servicemonitors "all" {
  forward_to = [prometheus.remote_write.mimir.receiver]
}

// Send discovered metrics to Mimir
prometheus.remote_write "mimir" {
  endpoint {
    url = "http://{{ include "lgtm-stack.componentSVC" "mimir" }}:8080/api/v1/push"
    headers = {
      "X-Scope-OrgID" = "{{ .Release.Name }}",
    }
  }
}

// --- Kubernetes Infrastructure Metrics ---

// Discover Kubelet and cAdvisor endpoints
discovery.kubernetes "nodes" {
  role = "node"
}

// Scrape Kubelet (node stats)
prometheus.scrape "kubelet" {
  targets    = discovery.kubernetes.nodes.targets
  scheme     = "https"
  bearer_token_file = "/var/run/secrets/kubernetes.io/serviceaccount/token"
  tls_config {
    ca_file = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
    insecure_skip_verify = true
  }
  forward_to = [prometheus.remote_write.mimir.receiver]
}

// Scrape cAdvisor (container stats)
prometheus.scrape "cadvisor" {
  targets    = discovery.kubernetes.nodes.targets
  scheme     = "https"
  bearer_token_file = "/var/run/secrets/kubernetes.io/serviceaccount/token"
  metrics_path = "/metrics/cadvisor"
  tls_config {
    ca_file = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
    insecure_skip_verify = true
  }
  forward_to = [prometheus.remote_write.mimir.receiver]
}

// Discover pods for metrics (separate from your log discovery)
discovery.kubernetes "annotated_pods" {
  role = "pod"
}

// Filter and transform targets based on annotations
discovery.relabel "prometheus_annotations" {
  targets = discovery.kubernetes.annotated_pods.targets

  // Only scrape pods where prometheus.io/scrape: "true"
  rule {
    source_labels = ["__meta_kubernetes_pod_annotation_prometheus_io_scrape"]
    action        = "keep"
    regex         = "true"
  }

  // Handle prometheus.io/path (default to /metrics if missing)
  rule {
    action       = "replace"
    replacement  = "/metrics"
    target_label = "__metrics_path__"
  }

  rule {
    source_labels = ["__meta_kubernetes_pod_annotation_prometheus_io_path"]
    action        = "replace"
    target_label  = "__metrics_path__"
    regex         = "(.+)"
    replacement   = "$1"
  }

  // Handle prometheus.io/port and update __address__
  // This replaces the pod's default IP:PORT with PodIP:CustomPort
  rule {
    source_labels = ["__address__", "__meta_kubernetes_pod_annotation_prometheus_io_port"]
    action        = "replace"
    regex         = "([^:]+)(?::\\d+)?;(\\d+)"
    replacement   = "$1:$2"
    target_label  = "__address__"
  }

  // Optional: Map pod labels to your metrics for better querying
  rule {
    action = "labelmap"
    regex  = "__meta_kubernetes_pod_label_(.+)"
  }
}

// Scrape the filtered targets and send to Mimir
prometheus.scrape "annotated_pods" {
  targets    = discovery.relabel.prometheus_annotations.output
  forward_to = [prometheus.remote_write.mimir.receiver]
}

// Receive OTLP data from your OTel Collector
otelcol.receiver.otlp "default" {
  grpc {
    endpoint = "0.0.0.0:4317"
  }
  http {
    endpoint = "0.0.0.0:4318"
  }

  output {
    metrics = [otelcol.processor.batch.default.input]
    logs    = [otelcol.processor.batch.default.input]
    traces  = [otelcol.processor.batch.default.input]
  }
}

// Batch the data
otelcol.processor.batch "default" {
  output {
    metrics = [otelcol.exporter.prometheus.mimir.input]
    logs    = [otelcol.exporter.loki.default.input]
    traces  = [otelcol.exporter.otlp.tempo.input]
  }
}

// Convert OTel Metrics to Prometheus format and send to your Mimir block
otelcol.exporter.prometheus "mimir" {
  forward_to = [prometheus.remote_write.mimir.receiver]
}

// Convert OTel Logs to Loki format and send to your Loki block
otelcol.exporter.loki "default" {
  forward_to = [loki.write.default.receiver]
}

// Send Traces to Tempo (OTLP natively)
otelcol.exporter.otlp "tempo" {
  client {
    endpoint = "{{ include "lgtm-stack.componentSVC" "tempo" }}:4317"
    tls {
      insecure = true
    }
  }
}

{{- end -}}

