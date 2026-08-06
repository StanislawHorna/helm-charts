{{- define "outline.appName" -}}
outline
{{- end -}}
{{- define "outline.cache.appName" -}}
outline-cache
{{- end -}}

{{- define "outline.serviceName" -}}
{{ include "outline.appName" . }}-svc
{{- end -}}

{{- define "outline.cache.serviceName" -}}
{{ include "outline.cache.appName" . }}-svc
{{- end -}}


{{- define "outline.labels" -}}
app: "outline"
component: "server"
{{- end -}}

{{- define "outline.server.http.port" -}}
3000
{{- end -}}


{{- define "outline.cache.hostname" -}}
{{ include "outline.cache.serviceName" . }}.{{ .Release.Namespace }}
{{- end -}}

{{- define "outline.db.clusterName" -}}
outline-db
{{- end -}}
{{- define "outline.db.hostname" -}}
{{ include "outline.db.clusterName" . }}-rw.{{ .Release.Namespace }}
{{- end -}}
{{- define "outline.db.databaseName" -}}
outline-db
{{- end -}}
{{- define "outline.db.username" -}}
outline-user
{{- end -}}

{{- define "outline.db.secretDetails.key_name" -}}
outline-database
{{- end -}}

{{- define "outline.db.secretDetails" -}}
- key_name_prefix: {{ .Values.database.kvPrefix}}
  key_name: {{ include "outline.db.secretDetails.key_name" . }}
  service_hostname: {{ .Values.gateway.hostname }}
  properties:
    - name: hostname
      value: {{ include "outline.db.hostname" . }}
    - name: database
      value: {{ include "outline.db.databaseName" . }}
    - name: username
      value: {{ include "outline.db.username" . }}
    - name: password
      value_length: 32
{{- end -}}

{{- define "outline.appSecret.key_name" -}}
outline-app-secret
{{- end -}}
{{- define "outline.appSecret" -}}
- key_name_prefix: {{ .Values.outline.appSecret.kvPrefix }}
  key_name: {{ include "outline.appSecret.key_name" . }}
  service_hostname: {{ .Values.outline.rootURL | trimPrefix "https://" | trimPrefix "http://" }}
  properties:
    - name: SECRET_KEY
      value_length: 64
    - name: UTILS_SECRET
      value_length: 64
{{- end -}}

{{- define "outline.authentikOAuthSecrets.key_name" -}}
outline-oauth
{{- end -}}
{{- define "outline.authentikOAuthSecrets" -}}
- key_name_prefix: {{ .Values.outline.generateAuthentikOAuthSecrets.kvPrefix }}
  key_name: {{ include "outline.authentikOAuthSecrets.key_name" . }}
  service_hostname: {{ .Values.outline.generateAuthentikOAuthSecrets.authentikHost | trimPrefix "https://" | trimPrefix "http://" }}
  properties:
    - name: OIDC_CLIENT_ID
      value: "outline"
    - name: OIDC_CLIENT_SECRET
      value_length: 32
    - name: OIDC_ISSUER_URL
      value: "{{ .Values.outline.generateAuthentikOAuthSecrets.authentikHost }}/application/o/outline/"
    - name: OIDC_SCOPES
      value: "openid profile email entitlements groups"
    - name: OIDC_DISPLAY_NAME
      value: "Authentik"
{{- end -}}