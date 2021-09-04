{{/*
Expand the name of the chart.
*/}}
{{- define "polaris.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "polaris.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "polaris.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "polaris.labels" -}}
helm.sh/chart: {{ include "polaris.chart" . }}
{{ include "polaris.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "polaris.selectorLabels" -}}
app.kubernetes.io/name: {{ include "polaris.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the webserver service account to use
*/}}
{{- define "webserver.serviceAccountName" -}}
{{- if .Values.webserver.serviceAccount.create }}
{{- default (include "polaris.fullname" .) .Values.webserver.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.webserver.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the worker service account to use
*/}}
{{- define "worker.serviceAccountName" -}}
{{- if .Values.worker.serviceAccount.create }}
{{- default (include "polaris.fullname" .) .Values.worker.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.worker.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the migrate service account to use
*/}}
{{- define "migrate.serviceAccountName" -}}
{{- if .Values.migrate.serviceAccount.create }}
{{- default (include "polaris.fullname" .) .Values.migrate.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.migrate.serviceAccount.name }}
{{- end }}
{{- end }}
