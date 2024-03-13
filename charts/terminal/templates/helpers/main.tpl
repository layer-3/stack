{{/* vim: set filetype=mustache: */}}
{{/*
Kong Service Name
*/}}
{{- define "main.kongSvcName" -}}
{{- printf "%s-%s-%s" .Release.Name .Values.global.kong.nameOverride .Values.global.kong.svcType }}
{{- end }}

{{/*
Secret environment variable template
with opendax-global Secret backwards compatibility
*/}}
{{- define "main.opendaxGlobalVarReplace" -}}
- name: {{ default .name .nameOverride }}
  valueFrom:
    secretKeyRef:
      {{- if eq (default "vault" .Values.global.kaigara.storageDriver) "k8s" }}
      name: {{ printf "kaigara-%s" .secretApp }}
      key: {{ .name }}
      {{- else }}
      name: {{ .Values.global.secretPrefix }}-global
      key: {{ .key }}
      {{- end }}
{{- end }}

{{/*
Returns pod annotations snippet depending on input Values
*/}}
{{- define "main.withGlobalAnnotations" -}}
{{- range $key, $value := .Values.global.podAnnotations }}
{{ printf "\"%s\": \"%s\"" $key (print $value) }}
{{- end }}
{{- range $key, $value := .Values.podAnnotations }}
{{ printf "\"%s\": \"%s\"" $key (print $value) }}
{{- end }}
{{- end }}
