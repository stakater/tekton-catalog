{{/*
Expand the name of the chart.
*/}}
{{- define "stakater-helm-push.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}

