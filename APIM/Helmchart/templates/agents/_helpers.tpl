{{- define "discoveryAgent.name" -}}
{{- if .Values.agents.discovery.nameOverride -}}
{{ .Values.agents.discovery.nameOverride }}
{{- else -}}
{{- default .Chart.Name .Values.agents.discovery.nameOverride | trunc 63 | trimSuffix "-" -}}-discoveryagent
{{- end -}}
{{- end -}}

{{- define "traceabilityAgent.name" -}}
{{- if .Values.agents.traceability.nameOverride -}}
{{ .Values.agents.traceability.nameOverride }}
{{- else -}}
{{- default .Chart.Name .Values.agents.traceability.nameOverride | trunc 63 | trimSuffix "-" -}}-traceabilityagent
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "discoveryAgent.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Values.global.imageTag | quote }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "discoveryAgent.selectorLabels" . }}
{{- end }}

{{- define "traceabilityAgent.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Values.global.imageTag | quote }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "traceabilityAgent.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "discoveryAgent.selectorLabels" -}}
app.kubernetes.io/component: "discoveryAgent"
app.kubernetes.io/name: {{ include "discoveryAgent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- range $key, $value := .Values.agents.discovery.labels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}

{{- define "traceabilityAgent.selectorLabels" -}}
app.kubernetes.io/component: "traceabilityAgent"
app.kubernetes.io/name: {{ include "traceabilityAgent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- range $key, $value := .Values.agents.traceability.labels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
Agents ImagePullPolicy
*/}}
{{- define "imagePullPolicy" -}}
{{- if .Values.agents.imagePullPolicy }}{{ .Values.agents.imagePullPolicy }}{{- else }}{{ .Values.global.imagePullPolicy }}{{- end }}
{{- end }}

{{/*
Discovery-Agent secret name
*/}}
{{- define "discoveryAgentSecretName" -}}

{{- if .Values.agents.discovery.existingSecret  -}}
{{ .Values.agents.discovery.existingSecret | quote }}
{{- else -}}
{{ template "discoveryAgent.name" . }}
{{- end -}}

{{- end -}}

{{/*
Traceability-Agent secret name
*/}}
{{- define "traceabilityAgentSecretName" -}}

{{- if .Values.agents.traceability.existingSecret  -}}
{{ .Values.agents.traceability.existingSecret | quote }}
{{- else -}}
{{ template "traceabilityAgent.name" . }}
{{- end -}}

{{- end -}}