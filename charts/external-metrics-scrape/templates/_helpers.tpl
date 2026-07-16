{{/* Check if ServiceMonitor CRD is installed */}}
{{- define "external-metrics-scrape.hasServiceMonitor" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1" -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/* Check if ExternalSecrets CRD is installed */}}
{{- define "external-metrics-scrape.hasExternalSecrets" -}}
{{- if .Capabilities.APIVersions.Has "external-secrets.io/v1" -}}
  {{- true -}}
{{- end -}}
{{- end -}}
