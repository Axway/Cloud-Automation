{{/*
API-Manager ImageTag
*/}}
{{- define "apimgrImageTag" -}}
{{- if .Values.apimgr.imageTag }}{{ .Values.apimgr.imageTag }}{{- else }}{{ required "Either apimgr.imageTag or global.imageTag is required. Please configure your values.yaml accordingly." .Values.global.imageTag }}{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "apimgr.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Values.global.imageTag | quote }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "apimgr.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "apimgr.selectorLabels" -}}
app.kubernetes.io/component: "apimgr"
app.kubernetes.io/name: {{ include "apimgr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- range $key, $value := .Values.apimgr.labels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
API-Manager ImagePullPolicy
*/}}
{{- define "imagePullPolicy" -}}
{{- if .Values.apimgr.imagePullPolicy }}{{ .Values.apimgr.imagePullPolicy }}{{- else }}{{ .Values.global.imagePullPolicy }}{{- end }}
{{- end }}