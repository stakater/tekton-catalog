{{/*
Expand the name of the chart.
*/}}
{{- define "stakater-sonarqube-scanner.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}
