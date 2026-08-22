{{ define "volumes" }}
- name: media-volume
  persistentVolumeClaim:
    claimName: media-pvc
- name: custom-pipelines-volume
  configMap:
    name: netbox-custom-pipelines
    items:
      {{- $files := .Files.Glob "files/custom_pipelines/*.py" }}
      {{- range $path, $bytes := $files }}
      - key: {{ base $path }}
        path: {{ base $path }}
      {{- end }}
- name: ca-volume
  secret:
    secretName: self-signed-root-ca
- name: combined-ca-volume
  emptyDir: {}
{{ end }}

{{ define "volumeMounts" }}
- name: media-volume
  mountPath: "{{ include "netbox.mediaRoot" . }}"
- name: ca-volume
  mountPath: /tmp/ca-secret/root-ca.crt
  subPath: root-ca.crt
- name: combined-ca-volume
  mountPath: /tmp/ca-bundle
{{- $files := .Files.Glob "files/custom_pipelines/*.py" }}
{{- range $path, $bytes := $files }}
- name: custom-pipelines-volume
  mountPath: /etc/netbox/config/{{ base $path }}
  subPath: {{ base $path }}
{{- end }}
{{ end }}

{{ define "env" }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-creds
      key: password
- name: SSL_CERT_FILE
  value: "/tmp/ca-bundle/combined-ca-certificates.crt"
- name: REQUESTS_CA_BUNDLE
  value: "/tmp/ca-bundle/combined-ca-certificates.crt"
{{ end }}

{{ define "envFrom" }}
- configMapRef:
    name: netbox-env-config
- secretRef:
    name: db-creds
- secretRef:
    name: {{ include "netbox.bootstrap.key_name" . }}
- secretRef:
    name: {{ include "netbox.oauth.key_name" . }}
{{ end }}

{{ define "initContainer.merge-ca-bundle" }}
- name: merge-ca-bundle
  image: "{{ .Values.netbox.image.name }}:{{ .Values.netbox.image.tag }}"
  command:
    - sh
    - -c
    - |
      # Concatenate all .crt files in the mounted directory with the system bundle
      cat /etc/ssl/certs/ca-certificates.crt /tmp/ca-secret/*.crt > /tmp/ca-bundle/combined-ca-certificates.crt
  volumeMounts:
    {{- include "volumeMounts" . | indent 4 }}
{{ end }}