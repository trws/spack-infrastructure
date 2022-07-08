#! /usr/bin/env bash

set -eo pipefail

s_namespace="$1" ; shift
s_svc="$1" ; shift
s_username="$1" ; shift
s_password="$1" ; shift

d_namespace="$1" ; shift
d_svc="$1" ; shift
d_username="$1" ; shift
d_password="$1" ; shift

pod_name="$1" ; shift

# kubectl apply -f << EOF
cat << EOF
---
apiVersion: v1
kind: Pod
metadata:
  name: "$pod_name"
spec:
  restartPolicy: Never
  containers:
    - name: migrate
      image: postgres:alpine
      command: [/bin/bash, -c]
      args:
        - |
          PGPASSWORD="$s_password" \
              pg_dumpall -h "$s_svc.$s_namespace" -U "$s_username" > dump.sql

          PGPASSWORD="$d_password" \
              psql -h "$d_svc.$d_namespace" -U "$d_username" < dump.sql
EOF
