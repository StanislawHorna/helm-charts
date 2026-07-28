{{/* Check if ExternalSecrets CRD is installed */}}
{{- define "rust-fs.hasExternalSecrets" -}}
{{- if .Capabilities.APIVersions.Has "external-secrets.io/v1" -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{- define "rust-fs.appName" -}}
rust-fs
{{- end -}}

{{- define "rust-fs.serviceName" -}}
rust-fs
{{- end -}}

{{/*
Transforms a list of buckets into a map keyed by serviceName, then outputs it as JSON
*/}}
{{- define "rust-fs.s3ObjectsMapJson" -}}
  {{- $result := dict -}}
  {{- range .Values.s3Objects.buckets }}
    {{- $bucketMap := dict "serviceName" .serviceName "bucketName" .bucketName -}}
    {{- $_ := set $result .serviceName $bucketMap -}}
  {{- end }}
  {{- $result | toJson -}}
{{- end -}}

{{- define "rust-fs.admin.credentials.key_name_prefix" -}}
rust-fs
{{- end -}}
{{- define "rust-fs.admin.credentials.key_name" -}}
admin-credentials
{{- end -}}

{{- define "rust-fs.admin.credentials.access_key" -}}
TF_VAR_MINIO_USER
{{- end -}}
{{- define "rust-fs.admin.credentials.secret_key" -}}
TF_VAR_MINIO_PASSWORD
{{- end -}}

{{- define "rust-fs.admin.credentials" -}}
- key_name_prefix: {{ include "rust-fs.admin.credentials.key_name_prefix" . }}
  key_name: {{ include "rust-fs.admin.credentials.key_name" . }}
  service_hostname: {{ .Values.rustFS.gateway.apiHostname }}
  properties:
    - name: TF_VAR_MINIO_ENDPOINT
      value: "{{ include "rust-fs.serviceName" . }}:9000"
    - name: TF_VAR_MINIO_ENABLE_HTTPS
      value: "false"
    - name: {{ include "rust-fs.admin.credentials.access_key" . }}
      value_length: 16
    - name: {{ include "rust-fs.admin.credentials.secret_key" . }}
      value_length: 16
{{- end -}}

{{- define "rust-fs.authentikOAuthSecrets.key_name" -}}
rust-fs-oauth
{{- end -}}
{{- define "rust-fs.authentikOAuthSecrets" -}}
- key_name_prefix: {{ .Values.rustFS.generateAuthentikOAuthSecrets.kvPrefix }}
  key_name: {{ include "rust-fs.authentikOAuthSecrets.key_name" . }}
  service_hostname: {{ .Values.rustFS.generateAuthentikOAuthSecrets.authentikHost | trimPrefix "https://" | trimPrefix "http://" }}
  properties:
    - name: RUSTFS_IDENTITY_OPENID_ENABLE
      value: "true"
    - name: RUSTFS_IDENTITY_OPENID_DISPLAY_NAME
      value: "Authentik"
    - name: RUSTFS_IDENTITY_OPENID_CLIENT_ID
      value: "rustfs"
    - name: RUSTFS_IDENTITY_OPENID_CLIENT_SECRET
      value_length: 32
    - name: RUSTFS_IDENTITY_OPENID_CLAIM_NAME
      value: "policy"
    - name: RUSTFS_IDENTITY_OPENID_CONFIG_URL
      value: "{{ .Values.rustFS.generateAuthentikOAuthSecrets.authentikHost }}/application/o/rustfs/.well-known/openid-configuration"
    - name: RUSTFS_IDENTITY_OPENID_SCOPES
      value: "openid profile email entitlements groups"
{{- end -}}