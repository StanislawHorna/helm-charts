{{- define "netbox.appName" -}}
netbox
{{- end -}}

{{- define "netbox.serviceName" -}}
{{ include "netbox.appName" . }}-svc
{{- end -}}

{{- define "netbox.mediaRoot" -}}
/opt/netbox/netbox/media
{{- end -}}

{{- define "netbox.server.http.port" -}}
8080
{{- end -}}

{{- define "netbox.bootstrap.key_name" -}}
netbox-app-bootstrap
{{- end -}}

{{- define "netbox.bootstrap" -}}
- key_name_prefix: {{ .Values.secretsGenerator.kvPrefix }}
  key_name: {{ include "netbox.bootstrap.key_name" . }}
  service_hostname: {{ .Values.gateway.hostname }}
  properties:
    - name: SUPERUSER_NAME
      value: {{ .Values.netbox.adminBootstrap.username }}
    - name: SUPERUSER_EMAIL
      value: {{ .Values.netbox.adminBootstrap.email }}
    - name: SUPERUSER_PASSWORD
      value_length: 32
    - name: SUPERUSER_API_TOKEN
      value_length: 40
    - name: SUPERUSER_API_KEY
      value_length: 40
    - name: SECRET_KEY
      value_length: 64
    - name: API_TOKEN_PEPPER_1
      value_length: 64
{{- end -}}

{{- define "netbox.oauth.key_name" -}}
netbox-oauth
{{- end -}}

{{- define "netbox.oauth" -}}
- key_name_prefix: {{ .Values.generateAuthentikOAuthSecrets.kvPrefix }}
  key_name: {{ include "netbox.oauth.key_name" . }}
  service_hostname: {{ .Values.generateAuthentikOAuthSecrets.authentikHost | trimPrefix "https://" | trimPrefix "http://"  }}
  properties:
    - name: SOCIAL_AUTH_OIDC_OIDC_ENDPOINT
      value: {{ .Values.generateAuthentikOAuthSecrets.authentikHost }}/application/o/netbox/
    - name: SOCIAL_AUTH_OIDC_KEY
      value: "netbox"
    - name: SOCIAL_AUTH_OIDC_SECRET
      value_length: 32
    - name: SOCIAL_AUTH_OIDC_SCOPE
      value: "openid profile email entitlements groups"
{{- end -}}

