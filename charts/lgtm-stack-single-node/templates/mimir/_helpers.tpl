{{/*
Helper to convert duration to hours (minimum 1h)
Usage: {{ include "lgtm-stack.retentionHours" "1d" }}
*/}}
{{- define "lgtm-stack.retentionHours" -}}
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

{{- define "lgtm-stack.Mimir.DefaultLocalPath" -}}
  /data
{{- end -}}