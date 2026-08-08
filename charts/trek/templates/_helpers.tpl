{{- define "trek.appName" -}}
trek
{{- end -}}

{{- define "trek.labels" -}}
app: {{ include "trek.appName" . }}
component: "all-in-one"
{{- end -}}

{{- define "trek.serviceName" -}}
{{ include "trek.appName" . }}-svc
{{- end -}}
{{- define "trek.http.port" -}}
3000
{{- end -}}

{{- define "trek.bootstrap.key_name" -}}
trek-bootstrap
{{- end -}}
{{- define "trek.bootstrap" -}}
- key_name_prefix: {{ .Values.trek.adminBootstrap.kvPrefix}}
  key_name: {{ include "trek.bootstrap.key_name" . }}
  service_hostname: {{ .Values.trek.rootUrl | replace "https://" "" | replace "http://" ""  }}
  properties:
    - name: ADMIN_EMAIL
      value: {{ .Values.trek.adminBootstrap.email}}
    - name: ADMIN_PASSWORD
      value_length: 32
    - name: ENCRYPTION_KEY
      value_length: 32
{{- end -}}

{{- define "trek.authentikOAuthSecrets.key_name" -}}
trek-oauth
{{- end -}}
{{- define "trek.authentikOAuthSecrets" -}}
- key_name_prefix: {{ .Values.trek.generateAuthentikOAuthSecrets.kvPrefix }}
  key_name: {{ include "trek.authentikOAuthSecrets.key_name" . }}
  service_hostname: {{ .Values.trek.generateAuthentikOAuthSecrets.authentikHost | trimPrefix "https://" | trimPrefix "http://" }}
  properties:
    - name: OIDC_CLIENT_ID
      value: "trek"
    - name: OIDC_CLIENT_SECRET
      value_length: 32
    - name: OIDC_DISPLAY_NAME
      value: "Authentik"
    - name: OIDC_ADMIN_CLAIM
      value: "groups"
    - name: OIDC_ADMIN_VALUE
      value: "trek-admin"
    - name: OIDC_ISSUER
      value: "{{ .Values.trek.generateAuthentikOAuthSecrets.authentikHost }}/application/o/trek/"
    - name: OIDC_DISCOVERY_URL
      value: "{{ .Values.trek.generateAuthentikOAuthSecrets.authentikHost }}/application/o/trek/.well-known/openid-configuration"
    - name: OIDC_SCOPE
      value: "openid profile email entitlements groups"
{{- end -}}