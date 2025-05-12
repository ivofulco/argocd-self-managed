{{- define "prometheus.name" -}}
prometheus
{{- end }}

{{- define "prometheus.fullname" -}}
{{ .Release.Name }}-{{ include "prometheus.name" . }}
{{- end }}
