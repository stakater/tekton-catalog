{{/*
Expand the name of the chart.
*/}}
{{- define "stakater-validate-environment.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}
