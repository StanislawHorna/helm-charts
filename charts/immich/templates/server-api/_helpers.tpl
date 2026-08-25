{{- define "immich.server.api.appName" -}}
{{ include "immich.server.appName" . }}-api
{{- end -}}

{{- define "immich.server.api.serviceName" -}}
{{ include "immich.server.api.appName" . }}-svc
{{- end -}}

{{- define "immich.server.api.serviceMonitorName" -}}
{{ include "immich.server.api.appName" . }}-monitor
{{- end -}}

