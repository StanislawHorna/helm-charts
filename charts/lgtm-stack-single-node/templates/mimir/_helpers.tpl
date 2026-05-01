{{/*
Helper to convert duration to hours (minimum 1h)
Usage: {{ include "lgtm-stack.Mimir.hotStorage.retentionHours" "1d" }}
*/}}
{{- define "lgtm-stack.Mimir.hotStorage.retentionHours" -}}
  {{- $val := . | lower -}}
  {{- $num := (regexReplaceAll "[^0-9]" $val "") | atoi -}}
  {{- $unit := (regexReplaceAll "[0-9]" $val "") -}}
  
  {{- $hours := 0 -}}
  
  {{- if eq $unit "y" -}}
    {{- $hours = mul $num 8760 -}}
  {{- else if eq $unit "m" -}}
    {{- $hours = mul $num 720 -}}
  {{- else if eq $unit "d" -}}
    {{- $hours = mul $num 24 -}}
  {{- else if eq $unit "h" -}}
    {{- $hours = $num -}}
  {{- else -}}
    {{/* Default for minutes or unknown units: treat as < 1h */}}
    {{- $hours = 0 -}}
  {{- end -}}

  {{- if lt $hours 1 -}}
    {{- printf "1h" -}}
  {{- else -}}
    {{- printf "%vh" $hours -}}
  {{- end -}}
{{- end -}}

{{/*
Helper to add 24 hours to an existing hour-based duration string.
Usage: {{ include "lgtm-stack.add24h" "48h" }} -> "72h"
*/}}
{{- define "lgtm-stack.add24h" -}}
  {{- $currentHours := (regexReplaceAll "h" . "") | atoi -}}
  {{- $newTotal := add $currentHours 24 -}}
  {{- printf "%vh" $newTotal -}}
{{- end -}}

{{/*
Helper to to calculate max_query_parallelism and memcached max_idle_connections based on CPU limits.
Usage: {{ include "lgtm-stack.Mimir.parallelism" . }} -> returns double
*/}}
{{- define "lgtm-stack.Mimir.parallelism" -}}
  {{- $cpu := .Values.mimir.resources.limits.cpu | default "2" | toString | trimSuffix "m" | int -}}
  {{- printf "%v" (mul $cpu 4) -}}
{{- end -}}

{{- define "lgtm-stack.Mimir.defaultLocalPath" -}}
  /data
{{- end -}}

{{- define "lgtm-stack.Mimir.querySplit" -}}
  24h
{{- end -}}

{{- define "lgtm-stack.Mimir.maxOutstandingRequestsPerTenant" -}}
  {{- /* Get the querySplit value (e.g., "1h", "24h", "1d") */ -}}
  {{- $split := include "lgtm-stack.Mimir.querySplit" . | regexReplaceAll "h" "" | atoi  -}}
  
  {{- /* Prevent division by zero */ -}}
  {{- $split = max 1 $split -}}
  
  {{- /* 1. Math: Total hours in a year (8,760) divided by fraction, to get amount of requests needed to get a year data */ -}}
  {{- $chunksPerSeries := div 8760 $split -}}
  
  {{- /* 2. Multiply by a parallelism */ -}}
  {{- $calculated := mul $chunksPerSeries (include "lgtm-stack.Mimir.parallelism" .) -}}

  {{- /* 3. Multiply by a 30-panel safety factor per dashboard */ -}}
  {{- $calculated := mul $calculated 30 -}}

  {{- /* 5. Multiply by a 10 safety factor to allow long term queries for multiple users */ -}}
  {{- $calculated := mul $calculated 10 -}}
  
  {{- /* 6. Enforce a sensible floor limit of 4,096 */ -}}
  {{- $calculated := max 4096 $calculated -}}

  {{- /* 7. Enforce a ceiling limit of 1,000,000 */ -}}
  {{- min 1000000 $calculated -}}
{{- end -}}