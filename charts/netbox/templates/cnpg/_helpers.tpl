{{- define "db.clusterName" -}}
netbox-db
{{- end -}}

{{- define "db.hostname" -}}
{{ include "db.clusterName" . }}-rw.{{ .Release.Namespace }}
{{- end -}}

{{- define "db.databaseName" -}}
netbox-db
{{- end -}}

{{- define "db.username" -}}
netbox-user
{{- end -}}

{{- define "db.secretDetails.key_name" -}}
netbox-database
{{- end -}}

{{- define "db.secretDetails" -}}
- key_name_prefix: {{ .Values.database.vaultConfiguration.kvPrefix}}
  key_name: {{ include "db.secretDetails.key_name" . }}
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
