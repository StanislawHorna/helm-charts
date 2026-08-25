{{- define "immich.cache.appName" -}}
immich-cache
{{- end -}}

{{- define "immich.cache.serviceName" -}}
{{ include "immich.cache.appName" . }}-svc
{{- end -}}

{{- define "immich.cache.hostname" -}}
{{ include "immich.cache.serviceName" . }}.{{ .Release.Namespace }}
{{- end -}}
