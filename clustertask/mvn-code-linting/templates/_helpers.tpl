{{/*
Expand the name of the chart.
*/}}
{{- define "mvn-code-linting.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}
