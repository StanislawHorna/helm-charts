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
{{- end -}}

