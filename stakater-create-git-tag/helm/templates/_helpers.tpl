{{/*
Expand the name of the chart.
*/}}
{{- define "stakater-create-git-tag.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}
