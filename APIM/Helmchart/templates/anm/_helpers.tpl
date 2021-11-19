{{/*
Common labels
*/}}
{{- define "anm.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Values.global.imageTag | quote }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "anm.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "anm.selectorLabels" -}}
app.kubernetes.io/component: "anm"
app.kubernetes.io/name: {{ include "anm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- range $key, $value := .Values.anm.labels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
Admin-Node-Manager ImagePullPolicy
*/}}
{{- define "imagePullPolicy" -}}
{{- if .Values.anm.imagePullPolicy }}{{ .Values.anm.imagePullPolicy }}{{- else }}{{ .Values.global.imagePullPolicy }}{{- end }}
{{- end }}

{{/*
Admin-Node-Manager ImageTag
*/}}
{{- define "imageTag" -}}
{{- if .Values.anm.imageTag }}{{ .Values.anm.imageTag }}{{- else }}{{ required "Either anm.imageTag or global.imageTag is required. Please configure your values.yaml accordingly." .Values.global.imageTag }}{{- end }}
{{- end }}