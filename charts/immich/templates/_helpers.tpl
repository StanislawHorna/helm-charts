{{- define "immich.appName" -}}
immich
{{- end -}}

{{- define "immich.server.appName" -}}
{{ include "immich.appName" . }}-server
{{- end -}}

{{/*
Generates a persistence list dynamically by merging values.yaml keys with static paths.
*/}}
{{- define "immich.persistenceList" -}}
{{- /* Define your static internal container paths mapped to the values.yaml keys */ -}}
{{- $staticPaths := dict 
  "library"       "/data/library"
  "profiles"      "/data/profile"
  "thumbs"        "/data/thumbs"
  "encodedVideos" "/data/encoded-video"
  "uploads"       "/data/upload"
  "sqlDbBackups"  "/data/backups"
-}}
{{- range $key, $config := .Values.immich.persistence }}
  {{- if kindIs "map" $config }}
- name: {{ $key | lower }}-pvc
  size: {{ $config.size | quote }}
  storageClass: {{ $config.storageClass | quote }}
  mountPath: {{ index $staticPaths $key | default (printf "/usr/src/app/upload/%s" $key) }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "immich.server.volumes"}}
{{- range (include "immich.persistenceList" . | fromYamlArray)  }}
  - name: {{ .name }}
    persistentVolumeClaim:
      claimName: {{ .name }}
{{- end }}
{{- range .Values.immich.externalLibraries }}
  - name: {{ .name }}
    persistentVolumeClaim:
      claimName: {{ .name }}-pvc
{{- end }}
  - name: ca-volume
    secret:
      secretName: self-signed-root-ca
{{- end}}

{{- define "immich.server.volumeMounts" -}}
{{- range (include "immich.persistenceList" . | fromYamlArray)  }}
  - mountPath: {{ .mountPath }}
    name: {{ .name }}
{{- end }}
{{- range .Values.immich.externalLibraries }}
  - mountPath: /mnt/external-library/{{ .name }}
    name: {{ .name }}
{{- end }}
  - name: ca-volume
    mountPath: /etc/ssl/certs/root-ca.crt
    subPath: root-ca.crt
{{- end -}}

{{- define "immich.server.initContainer"}}
- name: wait-for-db
  image: ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23
  command:
    - /bin/sh
    - -c
    - |
      echo "Waiting for database to become available..."
      until pg_isready -h "{{ include "db.hostname" . }}" -p 5432 -U "{{ include "db.username" . }}"; do
        echo "Database is not ready yet. Retrying in 2 seconds..."
        sleep 2
      done
      echo "Database is ready! Starting Immich Server..."
  resources:
    limits:
      cpu: 50m
      memory: 64Mi
    requests:
      cpu: 10m
      memory: 32Mi
{{- end}}

{{- define "immich.authentikOAuthSecrets.key_name" -}}
immich-oauth
{{- end -}}
{{- define "immich.authentikOAuthSecrets" -}}
- key_name_prefix: {{ .Values.generateAuthentikOAuthSecrets.kvPrefix }}
  key_name: {{ include "immich.authentikOAuthSecrets.key_name" . }}
  service_hostname: {{ .Values.generateAuthentikOAuthSecrets.authentikHost | trimPrefix "https://" | trimPrefix "http://" }}
  properties:
    - name: OAUTH_CLIENT_ID
      value: "immich"
    - name: OAUTH_CLIENT_SECRET
      value_length: 32
    - name: OAUTH_ISSUER_URL
      value: "{{ .Values.generateAuthentikOAuthSecrets.authentikHost }}/application/o/immich/.well-known/openid-configuration"
{{- end -}}