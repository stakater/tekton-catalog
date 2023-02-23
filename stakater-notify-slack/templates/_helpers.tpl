{{/*
Expand the name of the chart.
*/}}
{{- define "stakater-notify-slack.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}

