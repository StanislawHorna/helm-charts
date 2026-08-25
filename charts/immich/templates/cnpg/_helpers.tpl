{{- define "db.clusterName" -}}
immich-database
{{- end -}}
{{- define "db.hostname" -}}
{{ include "db.clusterName" . }}-rw.{{ .Release.Namespace }}
{{- end -}}
{{- define "db.databaseName" -}}
immich-db
{{- end -}}
{{- define "db.username" -}}
immich-user
{{- end -}}

{{- define "db.SecretDetails.key_name" -}}
immich-database
{{- end -}}

{{- define "db.secretDetails" -}}
- key_name_prefix: {{ .Values.database.vaultConfiguration.kvPrefix}}
  key_name: {{ include "db.SecretDetails.key_name" . }}
  service_hostname: {{ .Values.gateway.hostname }}
  properties:
    - name: hostname
      value: {{ include "db.hostname" . }}
    - name: database
      value: {{ include "db.databaseName" . }}
    - name: username
      value: {{ include "db.username" . }}
    - name: password
      value_length: 32
{{- end -}}