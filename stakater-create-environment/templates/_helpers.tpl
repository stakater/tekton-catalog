{{/*
Expand the name of the chart.
*/}}
{{- define "create-environment.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}

