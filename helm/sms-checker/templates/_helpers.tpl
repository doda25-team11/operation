{{/*
Common template helpers for the sms-checker chart.
These functions generate consistent names and labels across all resources.
*/}}

{{- define "sms-checker.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "sms-checker.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "sms-checker.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
