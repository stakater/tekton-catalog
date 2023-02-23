{{- define "stakater-set-commit-status.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}-{{ .Chart.Version }}
{{- end }}
