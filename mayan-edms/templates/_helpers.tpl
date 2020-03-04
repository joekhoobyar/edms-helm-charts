{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mayan-edms.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mayan-edms.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mayan-edms.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "mayan-edms.labels" -}}
helm.sh/chart: {{ include "mayan-edms.chart" . }}
{{ include "mayan-edms.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "mayan-edms.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mayan-edms.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "mayan-edms.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "mayan-edms.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Determine the fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "mayan-edms.postgresql.fullname" -}}
{{- if .Values.postgresql.fullnameOverride -}}
{{- .Values.postgresql.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Determine postgresql host based on use of postgresql dependency.
*/}}
{{- define "mayan-edms.postgresql.host" -}}
{{- template "mayan-edms.postgresql.fullname" . -}}
{{- end -}}

{{/*
Determine the fully qualified redis name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "mayan-edms.redis.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Determine redis host based on use of redis dependency.
*/}}
{{- define "mayan-edms.redis.host" -}}
{{- template "mayan-edms.redis.fullname" . -}}-redis-master
{{- end -}}

{{- define "mayan-edms.env.celery-broker-url" -}}
redis://:{{ .Values.redis.password }}@{{ template "mayan-edms.redis.host" . }}:{{ .Values.redis.redisPort }}/0
{{- end -}}

{{- define "mayan-edms.env.celery-result-backend" -}}
redis://:{{ .Values.redis.password }}@{{ template "mayan-edms.redis.host" . }}:{{ .Values.redis.redisPort }}/1
{{- end -}}

{{- define "mayan-edms.env.databases" -}}
{'default':{'ENGINE':'django.db.backends.postgresql','NAME':'{{ .Values.postgresql.postgresDatabase }}','PASSWORD':'{{ .Values.postgresql.postgresPassword }}','USER':'{{ .Values.postgresql.postgresUser }}','HOST':'{{ template "mayan-edms.postgresql.host" . }}'}}
{{- end -}}
