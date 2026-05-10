{{/* Check if ServiceMonitor CRD is installed */}}
{{- define "omada-exporter.hasServiceMonitor" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1" -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/* Check if ExternalSecrets CRD is installed */}}
{{- define "omada-exporter.hasExternalSecrets" -}}
{{- if .Capabilities.APIVersions.Has "external-secrets.io/v1" -}}
  {{- true -}}
{{- end -}}
{{- end -}}



{{- define "omada-exporter.appName" -}}
omada-exporter
{{- end -}}
{{- define "omada-exporter.serviceName" -}}
{{ include "omada-exporter.appName" . }}-svc
{{- end -}}