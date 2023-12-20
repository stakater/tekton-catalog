{{/*
Expand the name of the chart.
*/}}
{{- define "stakater-app-sync-and-wait.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}
