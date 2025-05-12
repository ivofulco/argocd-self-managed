{{- define "external-secrets.name" -}}
external-secrets
{{- end }}

{{- define "external-secrets.fullname" -}}
{{ .Release.Name }}-{{ include "external-secrets.name" . }}
{{- end }}
