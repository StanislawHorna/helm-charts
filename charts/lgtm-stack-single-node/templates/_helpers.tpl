{{/*
Expand the name of the chart.
*/}}
{{- define "lgtm-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "lgtm-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "lgtm-stack.labels" -}}
helm.sh/chart: {{ include "lgtm-stack.chart" . }}
{{ include "lgtm-stack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "lgtm-stack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lgtm-stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* Check if ServiceMonitor CRD is installed */}}
{{- define "lgtm-stack.hasServiceMonitor" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1" -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Convert any K8s memory string (e.g., "1Gi", "512Mi") to a raw MB integer.
Usage: {{ include "lgtm-stack.toMegabytes" "1Gi" }}
Usage: {{ include "lgtm-stack.toMegabytes" .Values.loki.cacheResources.limits.memory }}
*/}}
{{- define "lgtm-stack.toMegabytes" -}}
  {{- $mem := . -}}
  {{- if hasSuffix "Gi" $mem -}}
    {{- mul (trimSuffix "Gi" $mem | atoi) 1024 -}}
  {{- else if hasSuffix "Mi" $mem -}}
    {{- trimSuffix "Mi" $mem -}}
  {{- else -}}
    {{- $mem -}}
  {{- end -}}
{{- end -}}

{{/*
Smart Component Name: 
- If input is a string: use that string.
- If input is the global context (.): derive from directory.
- Use 'trimAll' to clean up potential whitespace.
*/}}
{{- define "lgtm-stack.componentName" -}}
  {{- if typeIs "string" . -}}
    {{- . | trimAll " " -}}
  {{- else -}}
    {{- base (dir .Template.Name) -}}
  {{- end -}}
{{- end -}}

{{/*
Component Prefix: 
Simply acts as a wrapper for the naming logic.
*/}}
{{- define "lgtm-stack.componentPrefix" -}}
{{- include "lgtm-stack.componentName" . -}}
{{- end -}}

{{/*
Deployment Name
*/}}
{{- define "lgtm-stack.componentDeployment" -}}
{{- include "lgtm-stack.componentPrefix" . }}
{{- end -}}

{{/*
App Name
*/}}
{{- define "lgtm-stack.componentAppName" -}}
{{- include "lgtm-stack.componentPrefix" . }}
{{- end -}}



{{/*
PVC Name: <component>-pvc
*/}}
{{- define "lgtm-stack.componentPVC" -}}
{{- include "lgtm-stack.componentPrefix" . }}-pvc
{{- end -}}

{{/*
SVC Name: <component>-svc
*/}}
{{- define "lgtm-stack.componentSVC" -}}
{{- include "lgtm-stack.componentPrefix" . }}-svc
{{- end -}}

{{/*
Config Name: <component>-config
*/}}
{{- define "lgtm-stack.componentConfig" -}}
{{- include "lgtm-stack.componentPrefix" . }}-config
{{- end -}}

{{/*
Monitor Name: <component>-monitor
*/}}
{{- define "lgtm-stack.componentMonitor" -}}
{{- include "lgtm-stack.componentPrefix" . }}-monitor
{{- end -}}

{{/*
Generate a memcached container definition.
Usage: {{ include "lgtm-stack.memcachedContainer" .Values.loki.cacheResources }}
*/}}
{{- define "lgtm-stack.memcachedContainer" -}}

- name: memcached
  image: memcached:1.6.24-alpine
  args:
    # -m Sets the memory limit in MB
    # -c Sets the max concurrent connections
    - "-m"
    - {{ include "lgtm-stack.toMegabytes" .limits.memory | quote }}
    - "-c"
    - "1024"
  resources:
    {{- toYaml . | nindent 4 }}
  ports:
    - containerPort: 11211
{{- end -}}
