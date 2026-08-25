{{- define "immich.server.worker.appName" -}}
{{ include "immich.server.appName" . }}-worker
{{- end -}}

{{- define "immich.server.worker.serviceName" -}}
{{ include "immich.server.worker.appName" . }}-svc
{{- end -}}

{{- define "immich.server.worker.serviceMonitorName" -}}
{{ include "immich.server.worker.appName" . }}-monitor
{{- end -}}
