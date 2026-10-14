{{- define "gatus.appName" -}}
gatus
{{- end -}}

{{- define "gatus.serviceName" -}}
{{ include "gatus.appName" . }}-svc
{{- end -}}

{{- define "gatus.deployment.labels" -}}
app: "gatus"
component: "server"
{{- end -}}

{{- define "gatus.http.port" -}}
8080
{{- end -}}
