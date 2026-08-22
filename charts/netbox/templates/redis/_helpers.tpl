{{/*
Redis Deployment
*/}}
{{- define "redis.appName" -}}
redis
{{- end -}}

{{- define "redis.port" -}}
6379
{{- end -}}

{{- define "redis.serviceName" -}}
{{ include "redis.appName" . }}-svc
{{- end -}}


{{/*
Cache Deployment
*/}}
{{- define "cache.appName" -}}
redis-cache
{{- end -}}

{{- define "cache.port" -}}
6379
{{- end -}}

{{- define "cache.serviceName" -}}
{{ include "cache.appName" . }}-svc
{{- end -}}

