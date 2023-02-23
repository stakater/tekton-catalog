{{/*
Expand the name of the chart.
*/}}
{{- define "mvn-lint-code.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}
