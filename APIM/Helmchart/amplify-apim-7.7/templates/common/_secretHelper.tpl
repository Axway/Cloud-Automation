{{- define "imagePullSecret" }}
{{- if eq .Values.global.createSecrets true }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.global.dockerRegistry.url (printf "%s:%s" .Values.global.dockerRegistry.username .Values.global.dockerRegistry.token | b64enc) | b64enc }}
{{- end }}
{{- end }}
