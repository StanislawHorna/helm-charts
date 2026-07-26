{{/* Check if ServiceMonitor CRD is installed */}}
{{- define "forgejo.hasServiceMonitor" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1" -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/* Check if CNPG Cluster CRD is installed */}}
{{- define "forgejo.hasCNPGCluster" -}}
{{- if .Capabilities.APIVersions.Has "postgresql.cnpg.io/v1" -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/* Check if ExternalSecrets CRD is installed */}}
{{- define "forgejo.hasExternalSecrets" -}}
{{- if .Capabilities.APIVersions.Has "external-secrets.io/v1" -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{- define "forgejo.runner.appName" -}}
forgejo-runner
{{- end -}}
{{- define "forgejo.runner.serviceName" -}}
{{ include "forgejo.runner.appName" . }}-svc
{{- end -}}

{{- define "forgejo.deployment.server.labels" -}}
app: "forgejo"
component: "server"
{{- end -}}
{{- define "forgejo.deployment.runner.labels" -}}
app: "forgejo"
component: "runner"
{{- end -}}


{{- define "forgejo.server.appName" -}}
forgejo-server
{{- end -}}

{{- define "forgejo.server.serviceName" -}}
{{ include "forgejo.server.appName" . }}-svc
{{- end -}}

{{- define "forgejo.db.clusterName" -}}
forgejo-db
{{- end -}}
{{- define "forgejo.db.hostname" -}}
{{ include "forgejo.db.clusterName" . }}-rw.{{ .Release.Namespace }}
{{- end -}}
{{- define "forgejo.db.databaseName" -}}
forgejo-db
{{- end -}}
{{- define "forgejo.db.username" -}}
forgejo-user
{{- end -}}

{{- define "forgejo.db.secretDetails.key_name" -}}
forgejo-database
{{- end -}}

{{- define "forgejo.db.secretDetails" -}}
- key_name_prefix: {{ .Values.database.kvPrefix}}
  key_name: {{ include "forgejo.db.secretDetails.key_name" . }}
  service_hostname: {{ .Values.gateway.hostname }}
  properties:
    - name: hostname
      value: {{ include "forgejo.db.hostname" . }}
    - name: database
      value: {{ include "forgejo.db.databaseName" . }}
    - name: username
      value: {{ include "forgejo.db.username" . }}
    - name: password
      value_length: 32
{{- end -}}

{{- define "forgejo.bootstrap.key_name" -}}
forgejo-bootstrap
{{- end -}}
{{- define "forgejo.bootstrap" -}}
- key_name_prefix: {{ .Values.forgejoBootstrap.kvPrefix}}
  key_name: {{ include "forgejo.bootstrap.key_name" . }}
  service_hostname: {{ .Values.gateway.hostname }}
  properties:
    - name: FORGEJO_ADMIN_USERNAME
      value: {{ .Values.forgejoBootstrap.adminUsername}}
    - name: FORGEJO_ADMIN_EMAIL
      value: {{ .Values.forgejoBootstrap.adminEmail}}
    - name: FORGEJO_ADMIN_PASSWORD
      value_length: 32
    - name: FORGEJO_ADMIN_ACCESS_TOKEN
      value_length: 64
{{- end -}}

{{- define "forgejo.authentikOAuthSecrets.key_name" -}}
forgejo-oauth
{{- end -}}
{{- define "forgejo.authentikOAuthSecrets" -}}
- key_name_prefix: {{ .Values.forgejo.generateAuthentikOAuthSecrets.kvPrefix }}
  key_name: {{ include "forgejo.authentikOAuthSecrets.key_name" . }}
  service_hostname: {{ .Values.forgejo.generateAuthentikOAuthSecrets.authentikHost | trimPrefix "https://" | trimPrefix "http://" }}
  properties:
    - name: FORGEJO_AUTH_GENERIC_OAUTH_CLIENT_ID
      value: "forgejo"
    - name: FORGEJO_AUTH_GENERIC_OAUTH_CLIENT_SECRET
      value_length: 32
    - name: FORGEJO_PROVIDER_NAME
      value: "Authentik"
    - name: FORGEJO_AUTHENTIK_ICON_URL
      value: "https://avatars.githubusercontent.com/u/82976448?s=500&v=4"
    - name: FORGEJO_AUTH_GENERIC_OAUTH_AUTH_URL
      value: "{{ .Values.forgejo.generateAuthentikOAuthSecrets.authentikHost }}/application/o/authorize/"
    - name: FORGEJO_AUTH_GENERIC_OAUTH_TOKEN_URL
      value: "{{ .Values.forgejo.generateAuthentikOAuthSecrets.authentikHost }}/application/o/token/"
    - name: FORGEJO_AUTH_GENERIC_OAUTH_API_URL
      value: "{{ .Values.forgejo.generateAuthentikOAuthSecrets.authentikHost }}/userinfo/"
    - name: FORGEJO_AUTH_AUTO_DISCOVER_URL
      value: "{{ .Values.forgejo.generateAuthentikOAuthSecrets.authentikHost }}/application/o/forgejo/.well-known/openid-configuration"
    - name: FORGEJO_AUTH_GENERIC_OAUTH_SCOPES
      value: "openid profile email entitlements groups"
{{- end -}}

{{- define "forgejo.server.env" -}}
- name: FORGEJO__database__PASSWD
  valueFrom:
    secretKeyRef:
      name: db-creds
      key: password
- name: CONFIG_FILE
  value: /var/lib/gitea/custom/conf/app.ini
- name: SSL_CERT_FILE
  value: /etc/ssl/certs/internal-ca.crt
{{- end -}}
{{- define "forgejo.server.envFrom" -}}
- configMapRef:
    name: forgejo-config
- secretRef:
    name: forgejo-bootstrap
- secretRef:
    name: forgejo-oauth
{{- end -}}

{{- define "forgejo.server.volumeMounts" -}}
- name: data-volume
  mountPath: /data
- name: var-gitea-volume
  mountPath: /var/lib/gitea
{{- if .Values.selfSingedRootCA.enabled }}
- name: ca-volume
  mountPath: /etc/ssl/certs/root-ca.crt
  subPath: root-ca.crt
{{- end }}
{{- end -}}

{{- define "forgejo.server.volumes" -}}
- name: data-volume
  persistentVolumeClaim:
    claimName: forgejo-data-pvc
- name: var-gitea-volume
  persistentVolumeClaim:
    claimName: forgejo-var-gitea-pvc
{{- if .Values.selfSingedRootCA.enabled }}
- name: ca-volume
  secret:
    secretName: self-signed-root-ca
{{- end }}
{{- end -}}

{{- define "forgejo.server.http.port" -}}
3000
{{- end -}}