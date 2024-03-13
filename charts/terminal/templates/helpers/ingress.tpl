{{/* vim: set filetype=mustache: */}}
{{/*
Returns Ingress API version depending on K8s cluster version
*/}}
{{- define "ingress.apiVersion" -}}
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.Version -}}
networking.k8s.io/v1
{{- else if semverCompare ">=1.14-0" .Capabilities.KubeVersion.Version -}}
networking.k8s.io/v1beta1
{{- else -}}
extensions/v1beta1
{{- end }}
{{- end }}

{{/*
Returns default Ingress annotations
*/}}
{{- define "ingress.defaultAnnotations" -}}
kubernetes.io/ingress.class: nginx
kubernetes.io/tls-acme: "true"
cert-manager.io/cluster-issuer:  "{{ .Values.tlsClusterIssuer }}"
{{- end }}

{{/*
Returns Ingress TLS configuration
*/}}
{{- define "ingress.tls" -}}
{{- if .Values.ingress.tls.enabled }}
{{- if not .hosts }}
{{- $_ := set . "hosts" (list .Values.externalHostname) }}
{{- end }}
tls:
  {{- range $host := .hosts }}
  - secretName: "{{ $host | replace "." "-" }}-tls"
    hosts:
      - "{{ $host }}"
  {{- end }}
{{- end }}
{{- end }}

{{/*
Returns Ingress host path configuration
*/}}
{{- define "ingress.path" -}}
- path: {{ default .Values.ingress.path .path }}
  {{- if semverCompare ">=1.18-0" .Capabilities.KubeVersion.Version }}
  pathType: Prefix
  {{- end }}
  backend:
    {{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.Version }}
    {{- $svc := .service }}
    service:
      name: {{ $svc.name }}
      port:
        number: {{ default $svc.port $svc.internalPort }}
    {{- else }}
    serviceName: {{ $svc.name }}
    servicePort: {{ default $svc.port $svc.internalPort }}
    {{- end }}
{{- end }}
