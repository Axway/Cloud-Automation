{{- define "anm.name" -}}
{{- if .Values.anm.nameOverride -}}
{{ .Values.anm.nameOverride }}
{{- else -}}
{{- default .Chart.Name .Values.anm.nameOverride | trunc 63 | trimSuffix "-" -}}-anm
{{- end -}}
{{- end -}}

{{- define "apimgr.name" -}}
{{- if .Values.apimgr.nameOverride -}}
{{ .Values.apimgr.nameOverride }}
{{- else -}}
{{- default .Chart.Name .Values.apimgr.nameOverride | trunc 63 | trimSuffix "-" -}}-apimgr
{{- end -}}
{{- end -}}

{{- define "apitraffic.name" -}}
{{- if .Values.apimgr.nameOverride -}}
{{ .Values.apitraffic.nameOverride }}
{{- else -}}
{{- default .Chart.Name .Values.apitraffic.nameOverride | trunc 63 | trimSuffix "-" -}}-traffic
{{- end -}}
{{- end -}}

{{- define "cassandra.name" -}}
{{- default .Chart.Name .Values.cassandra.nameOverride | trunc 63 | trimSuffix "-" -}}-cassandra
{{- end -}}