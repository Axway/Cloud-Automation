{{- define "validateDockerRepo" -}}
{{- required "Value global.dockerRepository is missing." .Values.global.dockerRepository }}
{{- end -}}

{{- define "licenseSecretName" -}}
{{- if .Values.global.existingLicenseSecret  -}}
{{ .Values.global.existingLicenseSecret }}
{{- else if .Values.global.license -}}
{{ default "axway-apim-license" .Values.global.existingLicenseSecret }}
{{- else -}}
{{ "" }}
{{- end -}}
{{- end -}}

{{/*
Admin Node Manager name
*/}}
{{- define "anm.name" -}}
{{- if .Values.anm.nameOverride -}}
{{ .Values.anm.nameOverride }}
{{- else -}}
{{- default .Chart.Name .Values.anm.nameOverride | trunc 63 | trimSuffix "-" -}}-anm
{{- end -}}
{{- end -}}

{{/*
API-Manager name - Short by default as it look nicer in the ANM-Topology view
*/}}
{{- define "apimgr.name" -}}
{{- if .Values.apimgr.nameOverride -}}
{{ .Values.apimgr.nameOverride }}
{{- else -}}
{{- "apimgr" -}}
{{- end -}}
{{- end -}}

{{/*
API-Traffic name - Short by default as it look nicer in the ANM-Topology view
*/}}
{{- define "apitraffic.name" -}}
{{- if .Values.apitraffic.nameOverride -}}
{{ .Values.apitraffic.nameOverride }}
{{- else -}}
{{- "traffic" -}}
{{- end -}}
{{- end -}}

{{/*
API-Portal name - Short by default as it look nicer in the ANM-Topology view
*/}}
{{- define "apiportal.name" -}}
{{- if .Values.apiportal.nameOverride -}}
{{ .Values.apiportal.nameOverride }}
{{- else -}}
{{- default .Chart.Name .Values.apiportal.nameOverride | trunc 63 | trimSuffix "-" -}}-apiportal
{{- end -}}
{{- end -}}

{{- define "cassandra.name" -}}
{{- default .Chart.Name .Values.cassandra.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mysqlmetrics.name" -}}
{{- default .Chart.Name .Values.mysqlmetrics.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mysqlapiportal.name" -}}
{{- default .Chart.Name .Values.mysqlapiportal.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Filebeat name 
*/}}
{{- define "filebeat.name" -}}
{{- if .Values.filebeat.nameOverride -}}
{{ .Values.filebeat.nameOverride }}
{{- else -}}
{{- "filebeat" -}}
{{- end -}}
{{- end -}}

{{/*
Traceability agent name
*/}}
{{- define "traceabilityAgent.name" -}}
{{- if .Values.amplifyTA.nameOverride -}}
{{ .Values.amplifyTA.nameOverride }}
{{- else -}}
{{- "amplify-ta" -}}
{{- end -}}
{{- end -}}

{{/*
Filebeat certificate secret name
*/}}
{{- define "filebeat.certSecret.name" -}}
{{- if .Values.filebeat.elasticsearchCaSecret }}{{ .Values.filebeat.elasticsearchCaSecret }}{{- else }}{{ template "filebeat.name" . }}-cert
{{- end }}
{{- end }}

{{/*
Return the secret with MySQL credentials as the Bitname chart does
*/}}
{{- define "mysql.metrics.secretName" -}}
    {{- if .Values.mysqlmetrics.auth.existingSecret -}}
        {{- printf "%s" .Values.mysqlmetrics.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" .Values.mysqlmetrics.fullnameOverride -}}
    {{- end -}}
{{- end -}}

{{/*
Return the secret with MySQL credentials as the Bitname chart does
*/}}
{{- define "mysql.apiportal.secretName" -}}
    {{- if .Values.mysqlapiportal.auth.existingSecret -}}
        {{- printf "%s" .Values.mysqlapiportal.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" .Values.mysqlapiportal.fullnameOverride -}}
    {{- end -}}
{{- end -}}