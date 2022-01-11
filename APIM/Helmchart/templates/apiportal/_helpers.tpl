{{/*
Common labels
*/}}
{{- define "apiportal.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Values.global.imageTag | quote }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "apiportal.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "apiportal.selectorLabels" -}}
app.kubernetes.io/component: "apiportal"
app.kubernetes.io/name: {{ include "apiportal.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- range $key, $value := .Values.apiportal.labels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
API-Portal dockerRepository
*/}}
{{- define "apiportalDockerRepository" -}}
{{- if .Values.apiportal.dockerRepository }}{{ .Values.apiportal.dockerRepository }}{{- else }}{{ .Values.global.dockerRepository }}{{- end }}
{{- end }}

{{/*
API-Portal ImagePullPolicy
*/}}
{{- define "imagePullPolicy" -}}
{{- if .Values.apiportal.imagePullPolicy }}{{ .Values.apiportal.imagePullPolicy }}{{- else }}{{ .Values.global.imagePullPolicy }}{{- end }}
{{- end }}

{{/*
API-Portal ImageTag
*/}}
{{- define "apiportalImageTag" -}}
{{- if .Values.apiportal.imageTag }}{{ .Values.apiportal.imageTag }}{{- else }}{{ .Values.global.imageTag }}{{- end }}
{{- end }}

{{/*
Labels for the API-Portal certificate secret
*/}}
{{- define "certificates.name" -}}
{{ include "apiportal.name" . }}-certificates
{{- end }}

{{/*
API-Portal certificate secret name which may return the existingSecret name
*/}}
{{- define "apiportalCertificateSecretName" -}}

{{- if .Values.apiportal.config.ssl.existingSecret  -}}
{{ .Values.apiportal.config.ssl.existingSecret | quote }}
{{- else -}}
{{ template "certificates.name" . }}
{{- end -}}

{{- end -}}

{{/*
Generate required API-Portal certificates 
*/}}
{{- define "apiportal.gen-certs" -}}
{{- $altNames := list "localhost" ( printf "%s" (include "apiportal.name" .) ) -}}
{{- $ca := genCA "apiportal-ca" 365 -}}
{{- $cert := genSignedCert ( include "apiportal.name" . ) nil $altNames 365 $ca -}}
apache-ca.crt: {{ $ca.Cert | b64enc }}
apache.crt: {{ $cert.Cert | b64enc }}
apache.key: {{ $cert.Key | b64enc }}
{{- end -}}