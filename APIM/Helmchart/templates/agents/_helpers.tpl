{{/*
Discovery agent name
*/}}
{{- define "discoveryAgent.name" -}}
{{- if .Values.agents.discovery.nameOverride -}}
{{ .Values.agents.discovery.nameOverride }}
{{- else -}}
{{- default .Chart.Name .Values.agents.discovery.nameOverride | trunc 63 | trimSuffix "-" -}}-discoveryagent
{{- end -}}
{{- end -}}

{{/*
Traceability agent name
*/}}
{{- define "traceabilityAgent.name" -}}
{{- if .Values.agents.traceability.nameOverride -}}
{{ .Values.agents.traceability.nameOverride }}
{{- else -}}
{{- default .Chart.Name .Values.agents.traceability.nameOverride | trunc 63 | trimSuffix "-" -}}-traceability
{{- end -}}
{{- end -}}

{{/*
Discovery agent common labels
*/}}
{{- define "discoveryAgent.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Values.global.imageTag | quote }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "discoveryAgent.selectorLabels" . }}
{{- end }}

{{/*
Traceability agent common labels
*/}}
{{- define "traceabilityAgent.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Values.global.imageTag | quote }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "traceabilityAgent.selectorLabels" . }}
{{- end }}

{{/*
Discovery agent selector labels
*/}}
{{- define "discoveryAgent.selectorLabels" -}}
app.kubernetes.io/component: "AxwayAmplifyAgent"
app.kubernetes.io/name: {{ include "discoveryAgent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- range $key, $value := .Values.agents.discovery.labels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
Traceability agent selector labels
*/}}
{{- define "traceabilityAgent.selectorLabels" -}}
app.kubernetes.io/component: "AxwayAmplifyAgent"
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
Agents secret name
*/}}
{{- define "agentSecretName" -}}

{{- if .Values.agents.existingSecret  -}}
{{ .Values.agents.existingSecret | quote }}
{{- else -}}
{{- .Chart.Name }}-amplify-agents-secret
{{- end -}}

{{- end -}}