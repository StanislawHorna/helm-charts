{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "argocd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "argocd.labels" -}}
helm.sh/chart: {{ include "argocd.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: argocd
{{- end -}}

{{- define "argocd.bootstrap.key_name" -}}
argocd-bootstrap
{{- end -}}
{{- define "argocd.bootstrap" -}}
- key_name_prefix: {{ .Values.bootstrap.kvPrefix}}
  key_name: {{ include "argocd.bootstrap.key_name" . }}
  service_hostname: {{ .Values.gateway.hostname }}
  properties:
    - name: "admin.password"
      value_length: 32
    - name: "server.secretkey"
      value_length: 32
{{- end -}}

{{/* Helper for Authentik Issuer URL */}}
{{- define "argocd.authentikIssuer" -}}
{{- printf "%s/application/o/argocd/" ( .Values.generateAuthentikOAuthSecrets.authentikHost | trimSuffix "/" ) -}}
{{- end -}}

{{- define "argocd.authentikOAuthSecrets.key_name" -}}
argocd-oauth
{{- end -}}
{{- define "argocd.authentikOAuthSecrets" -}}
- key_name_prefix: {{ .Values.generateAuthentikOAuthSecrets.kvPrefix }}
  key_name: {{ include "argocd.authentikOAuthSecrets.key_name" . }}
  service_hostname: {{ .Values.generateAuthentikOAuthSecrets.authentikHost | trimPrefix "https://" | trimPrefix "http://" }}
  properties:
    - name: "oidc.clientID"
      value: "argocd"
    - name: "oidc.clientSecret"
      value_length: 32
    - name: "oidc.issuer"
      value: "{{ include "argocd.authentikIssuer" . }}"
{{- end -}}