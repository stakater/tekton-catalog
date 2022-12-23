{{/*
Expand the name of the chart.
*/}}
{{- define "sonarqube-scan.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}
