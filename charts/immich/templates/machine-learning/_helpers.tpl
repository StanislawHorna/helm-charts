{{- define "immich.ml.appName" -}}
immich-machine-learning
{{- end -}}

{{- define "immich.ml.port" -}}
3003
{{- end -}}

{{- define "immich.ml.serviceName" -}}
{{ include "immich.ml.appName" . }}-svc
{{- end -}}

{{- define "immich.ml.url" -}}
http://{{ include "immich.ml.serviceName" . }}.{{ .Release.Namespace }}:{{ include "immich.ml.port" . }}
{{- end -}}


{{- define "immich.ml.cache.pvcName" -}}
{{ include "immich.ml.appName" . }}-cache-pvc
{{- end -}}
