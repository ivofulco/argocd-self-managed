{{- define "grafana.name" -}}
grafana
{{- end }}

{{- define "grafana.fullname" -}}
{{ .Release.Name }}-{{ include "grafana.name" . }}
{{- end }}
