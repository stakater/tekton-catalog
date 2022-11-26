{{/*
Expand the name of the chart.
*/}}
{{- define "stakater-github-update-cd-repo.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}
