{{/*
Expand the name of the chart.
*/}}
{{- define "stakater-fetch-pr-number.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}
