{{/* Check if ServiceMonitor CRD is installed */}}
{{- define "synology-exporter.hasServiceMonitor" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1" -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/* Check if ExternalSecrets CRD is installed */}}
{{- define "synology-exporter.hasExternalSecrets" -}}
{{- if .Capabilities.APIVersions.Has "external-secrets.io/v1" -}}
  {{- true -}}
{{- end -}}
{{- end -}}



{{- define "synology-exporter.appName" -}}
synology-exporter
{{- end -}}
{{- define "synology-exporter.serviceName" -}}
{{ include "synology-exporter.appName" . }}-svc
{{- end -}}