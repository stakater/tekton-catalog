{{/*
Expand the name of the chart.
*/}}
{{- define "stakater-push-main-tag.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}

