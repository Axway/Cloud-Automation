{{/*
Common labels
*/}}
{{- define "apitraffic.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Values.global.imageTag | quote }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "apitraffic.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "apitraffic.selectorLabels" -}}
app.kubernetes.io/component: "apitraffic"
app.kubernetes.io/name: {{ include "apitraffic.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- range $key, $value := .Values.apitraffic.labels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
API-Gateway Traffic ImagePullPolicy
*/}}
{{- define "imagePullPolicy" -}}
{{- if .Values.apitraffic.imagePullPolicy }}{{ .Values.apitraffic.imagePullPolicy }}{{- else }}{{ .Values.global.imagePullPolicy }}{{- end }}
{{- end }}

{{/*
API-Gateway Traffic ImageTag
*/}}
{{- define "apitrafficImageTag" -}}
{{- if .Values.apitraffic.imageTag }}{{ .Values.apitraffic.imageTag }}{{- else }}{{ .Values.global.imageTag }}{{- end }}
{{- end }}

{{- define "domain.name" -}}
{{ required "Either apimgr.ingress.name or global.domainName is required. Please configure your values.yaml accordingly." .Values.global.domainName }}
{{- end -}}