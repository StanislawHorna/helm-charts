{{- define "vikunja.appName" -}}
vikunja
{{- end -}}

{{- define "vikunja.serviceName" -}}
{{ include "vikunja.appName" . }}-svc
{{- end -}}

{{- define "vikunja.deployment.labels" -}}
app: "vikunja"
component: "server"
{{- end -}}

{{- define "vikunja.http.port" -}}
3456
{{- end -}}

{{- define "vikunja.authentikOAuthSecrets.key_name" -}}
vikunja-oauth
{{- end -}}
{{- define "vikunja.authentikOAuthSecrets" -}}
- key_name_prefix: {{ .Values.generateAuthentikOAuthSecrets.kvPrefix }}
  key_name: {{ include "vikunja.authentikOAuthSecrets.key_name" . }}
  service_hostname: {{ .Values.generateAuthentikOAuthSecrets.authentikHost | trimPrefix "https://" | trimPrefix "http://" }}
  properties:
    - name: VIKUNJA_AUTH_OPENID_ENABLED
      value: "true"
    - name: VIKUNJA_AUTH_OPENID_PROVIDERS_AUTHENTIK_NAME
      value: "Authentik"
    - name: VIKUNJA_AUTH_OPENID_PROVIDERS_AUTHENTIK_CLIENTID
      value: "vikunja"
    - name: VIKUNJA_AUTH_OPENID_PROVIDERS_AUTHENTIK_CLIENTSECRET
      value_length: 32
    - name: VIKUNJA_AUTH_OPENID_PROVIDERS_AUTHENTIK_AUTHURL
      value: "{{ .Values.generateAuthentikOAuthSecrets.authentikHost }}"
    - name: VIKUNJA_AUTH_OPENID_PROVIDERS_AUTHENTIK_SCOPE
      value: "openid profile email entitlements groups"
{{- end -}}