{{/* vim: set filetype=mustache: */}}
{{/*
Returns Cron Job API version depending on K8s cluster version
*/}}
{{- define "cronjob.apiVersion" -}}
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.Version -}}
batch/v1
{{- else -}}
batch/v1beta1
{{- end }}
{{- end }}

{{/*
Returns env mapping from Secret
*/}}
{{- define "hook.secretEnvs" -}}
{{- $hook := get .Values.hooks .hookName }}
{{- range $secret := $hook.secrets }}
{{- range $env, $rename := $secret.envs }}
- name: {{ default $env $rename }}
  valueFrom:
    secretKeyRef:
      {{- if $secret.this_release }}
      name: {{ printf "%s-%s" (include "component.fullname" $) $secret.name }}
      {{- else }}
      name: {{ $secret.name }}
      {{- end }}
      key: {{ $env }}
{{- end }}
{{- end }}
{{- end }}
