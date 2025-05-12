{{/*
Return the full name of the chart release
*/}}
{{- define "busybox-chart.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Return chart name
*/}}
{{- define "busybox-chart.name" -}}
{{- .Chart.Name -}}
{{- end }}
