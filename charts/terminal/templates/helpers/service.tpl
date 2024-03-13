{{/* vim: set filetype=mustache: */}}
{{/*
Returns service ports configuration depending on input service
*/}}
{{- define "service.port" -}}
- name: {{ kebabcase .name }}
  {{- if eq .type "NodePort" }}
  port: {{ default .port .internalPort }}
  {{- if .nodePort }}
  nodePort: {{ .nodePort }}
  {{- end }}
  {{- else }}
  port: {{ default .port .externalPort }}
  {{- end }}
  targetPort: {{ default .port .internalPort }}
  protocol: TCP
{{- end }}
