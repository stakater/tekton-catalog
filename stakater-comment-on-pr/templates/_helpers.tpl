{{/*
Expand the name of the chart.
*/}}
{{- define "stakater-comment-on-repo.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}

