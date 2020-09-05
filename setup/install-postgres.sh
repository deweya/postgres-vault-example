#!/bin/bash

## Add the bitnami chart repo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

## Install postgres and wait for postgres to become ready
if helm list -f postgres | grep postgres; then
  echo "ERROR: postgres already exists...exiting early..."
else
  echo "INFO: installing postgres via helm..."
  helm install postgres bitnami/postgresql --values postgres-values.yaml --wait
fi

## Port forward requests to postgres in the background
echo "INFO: Running kubectl port-forward in the background"
kubectl port-forward svc/postgres-postgresql 5432:5432 &
export PF_PID=$!
trap "kill $PF_PID" EXIT
echo "INFO: Waiting for port-forward to start"
sleep 5

## Configure postgres DB for demo
export PGPASSWORD=password
psql -h localhost -U postgres widget -f postgres-setup.sql