{{/*
Expand the name of the chart.
*/}}
{{- define "stakater-checkov-scan.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}

