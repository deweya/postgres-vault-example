#!/bin/bash

## Create vault-auth SA
if kubectl get sa vault-auth; then
  echo "INFO: serviceaccount 'vault-auth' already present"
else
  echo "INFO: creating serviceaccount 'vault-auth'..."
  kubectl create sa vault-auth
fi
kubectl apply -f vault-auth-service-account.yaml

## Install vault via Helm and wait for vault to become ready
if helm list -f vault | grep vault; then
  echo "ERROR: vault already exists...exiting early..."
else
  echo "INFO: installing vault via helm..."
  helm install vault hashicorp/vault --values vault-values.yaml --wait
  until [[ $(kubectl get statefulset vault -o jsonpath="{.status.readyReplicas}") == 1 ]]; do
    echo "INFO: waiting for vault to become ready..."
    sleep 5
  done
fi

## Port forward requests to vault in the background
export VAULT_ADDR=http://localhost:8200
echo "INFO: Running kubectl port-forward in the background"
kubectl port-forward svc/vault 8200:8200 &
export PF_PID=$!
trap "kill $PF_PID" EXIT
echo "INFO: Waiting for port-forward to start"
sleep 5

## Log into vault
echo "INFO: Logging into vault"
echo "root" | vault login -

## Create a read-only policy
echo "INFO: Creating a read-only policy"
vault policy write myapp-kv-ro - <<EOF
path "secret/data/myapp/*" {
    capabilities = ["read", "list"]
}
EOF

## Create some test data at the secret/myapp path
echo "INFO: Adding test data to secret/myapp/config"
vault kv put secret/myapp/config username='widget_blue' \
        password='password'

## Get SA JWT token and SA CA cert
echo "INFO: Getting SA JWT and CA"
export SA_SECRET=$(kubectl get sa vault-auth -o jsonpath="{.secrets[0].name}")
export SA_JWT_TOKEN=$(kubectl get secret $SA_SECRET \
    -o jsonpath="{.data.token}" | base64 --decode)
export SA_CA_CRT=$(kubectl get secret $SA_SECRET \
    -o jsonpath="{.data['ca\.crt']}" | base64 --decode)

## Enable kubernetes auth
echo "INFO: Enabling kubernetes auth"
vault auth enable kubernetes

## Configure kubernetes auth
echo "INFO: Configuring kubernetes auth"
vault write auth/kubernetes/config \
        token_reviewer_jwt="$SA_JWT_TOKEN" \
        kubernetes_host="https://kubernetes.default.svc:443" \
        kubernetes_ca_cert="$SA_CA_CRT"

## Create role
echo "INFO: Creating vault role"
vault write auth/kubernetes/role/example \
        bound_service_account_names=vault-auth \
        bound_service_account_namespaces=default \
        policies=myapp-kv-ro \
        ttl=24h
