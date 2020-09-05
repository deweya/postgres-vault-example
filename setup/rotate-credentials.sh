#!/bin/bash

## Port forward requests to postgres in the background
echo "INFO: Running kubectl port-forward in the background"
kubectl port-forward svc/postgres-postgresql 5432:5432 &
export PF_PID_POSTGRES=$!
trap "kill $PF_PID_POSTGRES" EXIT
echo "INFO: Waiting for port-forward to start"
sleep 5

## Add the widget_green role
export PGPASSWORD=password
psql -h localhost -U postgres widget -c "CREATE ROLE widget_green LOGIN PASSWORD 'widget_green_pass' IN ROLE widget;"

## Port forward requests to vault in the background
export VAULT_ADDR=http://localhost:8200
echo "INFO: Running kubectl port-forward in the background"
kubectl port-forward svc/vault 8200:8200 &
export PF_PID_VAULT=$!
trap "kill $PF_PID_VAULT" EXIT
echo "INFO: Waiting for port-forward to start"
sleep 5

## Log into vault
echo "INFO: Logging into vault"
echo "root" | vault login -

## Rotate the database credentials in Vault
vault kv put secret/myapp/config username=widget_green password=widget_green_pass