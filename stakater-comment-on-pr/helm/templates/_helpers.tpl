{{/*
Expand the name of the chart.
*/}}
{{- define "stakater-comment-on-pr.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}

