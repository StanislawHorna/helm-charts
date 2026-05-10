{{/* Check if ServiceMonitor CRD is installed */}}
{{- define "pve-exporter.hasServiceMonitor" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1" -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/* Check if ExternalSecrets CRD is installed */}}
{{- define "pve-exporter.hasExternalSecrets" -}}
{{- if .Capabilities.APIVersions.Has "external-secrets.io/v1" -}}
  {{- true -}}
{{- end -}}
{{- end -}}



{{- define "pve-exporter.appName" -}}
pve-exporter
{{- end -}}
{{- define "pve-exporter.serviceName" -}}
{{ include "pve-exporter.appName" . }}-svc
{{- end -}}