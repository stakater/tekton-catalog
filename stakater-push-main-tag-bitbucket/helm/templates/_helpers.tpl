{{/*
Expand the name of the chart.
*/}}
{{- define "stakater-push-main-tag-bitbucket.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}

