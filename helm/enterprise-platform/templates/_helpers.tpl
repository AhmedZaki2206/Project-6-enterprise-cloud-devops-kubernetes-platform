{{- define "enterprise-platform.name" -}}enterprise-platform{{- end }}
{{- define "enterprise-platform.fullname" -}}{{ .Release.Name }}{{- end }}
{{- define "enterprise-platform.labels" -}}
app.kubernetes.io/name: {{ include "enterprise-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
