{{/*
Expand the name of the chart.
*/}}
{{- define "stakater-rox-image-scan.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}
