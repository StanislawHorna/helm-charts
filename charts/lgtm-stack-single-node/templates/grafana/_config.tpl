{{/*
Default Grafana Configuration
*/}}
{{- define "lgtm-stack.grafanaDefaultConfig" -}}
{{- $rootUrl := "" -}}
{{- if .Values.grafana -}}
  {{- $rootUrl = .Values.grafana.rootUrl | default "" -}}
{{- end -}}
{{- $renderingTimezone := "Europe/Warsaw" -}}
{{- if .Values.grafana -}}
  {{- $renderingTimezone = .Values.grafana.renderingTimezone | default "Europe/Warsaw" -}}
{{- end -}}
[server]
root_url = {{ $rootUrl }}

[users]
default_theme = system
allow_sign_up = false
auto_assign_org_role = Viewer
home_page =

[auth.anonymous]
enabled = true
org_role = Viewer

[log]
mode = console file
level = info

[log.file]
format = json

[plugin.grafana-image-renderer]
rendering_timezone = "{{ $renderingTimezone }}"
{{- end -}}

{{/*
Default Grafana Datasources
*/}}
{{- define "lgtm-stack.grafanaDefaultDatasources" -}}
apiVersion: 1
datasources:
  - name: Mimir
    type: prometheus
    uid: mimir
    isDefault: true
    access: proxy
    url: http://{{ include "lgtm-stack.componentSVC" "mimir" }}:8080/prometheus
    jsonData:
      prometheusType: "Mimir"
      prometheusVersion: "2.9.1"
      httpMethod: POST
      httpHeaderName1: "X-Scope-OrgID"
      cacheLevel: "High"
      # Observability Loop: Link metrics to Tempo via Exemplars
      exemplarTraceIdDestinations:
        - datasourceUid: tempo
          name: traceID
    secureJsonData:
      httpHeaderValue1: "{{ .Release.Name }}"
  - name: Loki
    type: loki
    uid: loki
    access: proxy
    url: http://{{ include "lgtm-stack.componentSVC" "loki" }}:3100
    jsonData:
      derivedFields:
        - datasourceUid: tempo
          matcherRegex: "traceID=(\\w+)"
          name: TraceID
          url: "$${__value.raw}"
  - name: Tempo
    type: tempo
    uid: tempo
    access: proxy
    url: http://{{ include "lgtm-stack.componentSVC" "tempo" }}:3200
    jsonData:
      # Observability Loop: Link traces to Loki logs
      lokiSearch:
        datasourceUid: loki
      # Enable Node Graph (Service Map)
      nodeGraph:
        enabled: true
      # Link traces back to Mimir metrics
      serviceMap:
        datasourceUid: mimir
      traceQuery:
        lokiSidamEnabled: true
{{- end -}}
