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
Determine the fully qualified rabbitmq name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "mayan-edms.rabbitmq.fullname" -}}
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

{{/*
Determine rabbitmq host based on use of rabbitmq dependency.
*/}}
{{- define "mayan-edms.rabbitmq.host" -}}
{{- template "mayan-edms.rabbitmq.fullname" . -}}-rabbitmq
{{- end -}}

{{/*
Determine the value of the MAYAN_CELERY_BROKEN_URL env var.
*/}}
{{- define "mayan-edms.env.celery-broker-url" -}}
{{- if eq .Values.broker.type "rabbitmq" -}}
amqp://{{ .Values.rabbitmq.rabbitmq.username }}:{{ .Values.rabbitmq.rabbitmq.password }}@{{ template "mayan-edms.rabbitmq.host" . }}:{{ .Values.rabbitmq.service.port }}{{ .Values.broker.rabbitmqVhost }}
{{- else -}}
redis://:{{ .Values.redis.password }}@{{ template "mayan-edms.redis.host" . }}:{{ .Values.redis.redisPort }}/0
{{- end -}}
{{- end -}}

{{/*
Determine the value of the MAYAN_CELERY_RESULT_BACKEND env var.
*/}}
{{- define "mayan-edms.env.celery-result-backend" -}}
redis://:{{ .Values.redis.password }}@{{ template "mayan-edms.redis.host" . }}:{{ .Values.redis.redisPort }}/1
{{- end -}}

{{/*
Determine the value of the MAYAN_DATABASES env var.
*/}}
{{- define "mayan-edms.env.databases" -}}
{'default':{'ENGINE':'django.db.backends.postgresql','NAME':'{{ .Values.postgresql.postgresqlDatabase }}','PASSWORD':'{{ .Values.postgresql.postgresqlPassword }}','USER':'{{ .Values.postgresql.postgresqlUsername }}','HOST':'{{ template "mayan-edms.postgresql.host" . }}'}}
{{- end -}}

{{/*
Determine the value of the MAYAN_PIP_INSTALLS env var.
*/}}
{{- define "mayan-edms.env.pip-installs" -}}
{{- if .Values.objectstorage.enabled }} django-storages boto3{{- end -}}
{{- if eq .Values.broker.type "rabbitmq" }} amqp==2.5.2{{- end -}}
{{- end -}}

{{/*
Determine the value of the MAYAN_STORAGE_BACKEND_ARGUMENTS env var.
*/}}
{{- define "mayan-edms.env.storage-backend-args" -}}
{'bucket_name':'{{- .Values.objectstorage.bucketName -}}'
{{- if .Values.objectstorage.accessKey -}},'access_key':'{{- .Values.objectstorage.accessKey -}}'{{- end -}}
{{- if .Values.objectstorage.secretKey -}},'secret_key':'{{- .Values.objectstorage.secretKey -}}'{{- end -}}
{{- if .Values.objectstorage.defaultAcl -}},'default_acl':'{{- .Values.objectstorage.defaultAcl -}}'{{- end -}}
{{- if .Values.objectstorage.endpointUrl -}},'endpoint_url':'{{- .Values.objectstorage.endpointUrl -}}'{{- end -}}
,'verify':'{{- if .Values.objectstorage.verifyTls -}}true{{- else -}}false{{- end -}}'}
{{- end -}}
