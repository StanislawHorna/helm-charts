{{/* Check if ServiceMonitor CRD is installed */}}
{{- define "authentik.hasServiceMonitor" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1" -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/* Check if CNPG Cluster CRD is installed */}}
{{- define "authentik.hasCNPGCluster" -}}
{{- if .Capabilities.APIVersions.Has "postgresql.cnpg.io/v1" -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/* Check if ExternalSecrets CRD is installed */}}
{{- define "authentik.hasExternalSecrets" -}}
{{- if .Capabilities.APIVersions.Has "external-secrets.io/v1" -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{- define "authentik.worker.appName" -}}
authentik-worker
{{- end -}}
{{- define "authentik.worker.serviceName" -}}
{{ include "authentik.worker.appName" . }}-svc
{{- end -}}

{{- define "authentik.deployment.server.labels" -}}
app: "authentik"
component: "server"
{{- end -}}
{{- define "authentik.deployment.worker.labels" -}}
app: "authentik"
component: "worker"
{{- end -}}


{{- define "authentik.server.appName" -}}
authentik-server
{{- end -}}

{{- define "authentik.server.serviceName" -}}
{{ include "authentik.server.appName" . }}-svc
{{- end -}}

{{- define "authentik.db.clusterName" -}}
authentik-db
{{- end -}}
{{- define "authentik.db.hostname" -}}
{{ include "authentik.db.clusterName" . }}-rw.{{ .Release.Namespace }}
{{- end -}}
{{- define "authentik.db.databaseName" -}}
authentik-db
{{- end -}}
{{- define "authentik.db.username" -}}
authentik-user
{{- end -}}

{{- define "authentik.db.secretDetails.key_name" -}}
authentik-database
{{- end -}}

{{- define "authentik.db.secretDetails" -}}
- key_name_prefix: {{ .Values.database.kvPrefix }}
  key_name: {{ include "authentik.db.secretDetails.key_name" . }}
  service_hostname: {{ .Values.gateway.hostname }}
  properties:
    - name: hostname
      value: {{ include "authentik.db.hostname" . }}
    - name: database
      value: {{ include "authentik.db.databaseName" . }}
    - name: username
      value: {{ include "authentik.db.username" . }}
    - name: password
      value_length: 32
{{- end -}}

{{- define "authentik.bootstrap.key_name" -}}
authentik-bootstrap
{{- end -}}

{{- define "authentik.bootstrap" -}}
- key_name_prefix: {{ .Values.authentikBootstrap.kvPrefix}}
  key_name: {{ include "authentik.bootstrap.key_name" . }}
  service_hostname: {{ .Values.gateway.hostname }}
  properties:
    - name: AUTHENTIK_SECRET_KEY
      value_length: 16
    - name: AUTHENTIK_BOOTSTRAP_EMAIL
      value: {{ .Values.authentikBootstrap.adminEmail}}
    - name: AUTHENTIK_BOOTSTRAP_PASSWORD
      value_length: 32
    - name: AUTHENTIK_BOOTSTRAP_TOKEN
      value_length: 32
{{- end -}}