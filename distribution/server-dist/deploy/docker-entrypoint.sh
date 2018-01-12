#!/bin/bash
set -e
# set -x

if [ $KEYCLOAK_USER ] && [ $KEYCLOAK_PASSWORD ]; then
    /opt/keycloak/bin/add-user-keycloak.sh --user $KEYCLOAK_USER --password $KEYCLOAK_PASSWORD
fi

MYSQL_PROP_FILE=/etc/secrets/mariadb/mariadb.properties
VAULT_PROP_FILE=/etc/secrets/vault/vault.properties

file=$MYSQL_PROP_FILE
if [ -f "$file" ]
then
    echo "$file exist."
    while IFS='=' read -r key value || [[ -n "$key" ]]
    do
        key=$(echo $key | tr '.' '_')
        eval "${key}='${value}'"
    done < $file

#   cat $file
else
    echo >&2 "$file not exist."
    exit -1
fi

export MYSQL_PORT_3306_TCP_ADDR=$MYSQL_HOST
export MYSQL_PORT_3306_TCP_PORT=$MYSQL_PORT
export MYSQL_DATABASE=$MYSQL_SCHEMA

file=$VAULT_PROP_FILE
for ((i=1; i<=10; i++)); do
    if [ -f "$file" ]
    then
        break
    else
        # http://cmt/v1/vault/ping/$(hostname) need cmt-proxy
        # please use http://cmt.smec/v1/namespaces/$(namespace)/vault/ping/$(hostname) directly
        resp_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST -d "" "http://cmt.smec/v1/namespaces/${K8S_POD_NAMESPACE}/vault/ping/$(hostname)")
        exit_status=$?
        if [ $exit_status -ne 0 ]; then
            echo >&2 "ping cmt failed! exit code is $exit_status"
        fi
        if [ $resp_code = 404 ]; then
            break
        fi
        sleep 1
    fi
done

if [ -f "$file" ]
then
    echo "$file exist."
    while IFS='=' read -r key value || [[ -n "$key" ]]
    do
        key=$(echo $key | tr '.' '_')
        eval "${key}='${value}'"
    done < $file

#    cat $file
else
    echo >&2 "$file not exist."
    exit -1
fi

client_token=$(curl -sS -L -H "X-Vault-Token: ${VAULT_TOKEN}" ${VAULT_SERVER}/v1/cubbyhole/response | jq -r '.data.response|fromjson|.auth.client_token')

#connection_url=${VAULT_SERVER}/v1/cd/${KUBE_CLUSTER}.${NAMESPACE}/mysql/${SERVICE_NAME}/keycloakdb/config/connection
connection_url=${VAULT_SERVER}/v1/cd/${KUBE_CLUSTER}.${NAMESPACE}/mysql/mariadb/creds/${SERVICE_NAME}
response=$(curl -sS -L -H "X-Vault-Token: ${client_token}" ${connection_url})
credential=$(echo $response | jq -r '.data')
if [ -z "${credential}" ] || [ "$credential" = "null" ] ; then
    echo >&2 "credential is empty. response: $response"
    exit -1
fi
export MYSQL_USERNAME=$(echo $credential | jq -r '.username')
export MYSQL_PASSWORD=$(echo $credential| jq -r '.password')
if [ -z "${MYSQL_USERNAME}" ] || [ -z "${MYSQL_PASSWORD}" ] ; then
    echo >&2 "MYSQL_USERNAME/MYSQL_PASSWORD is empty."
    exit -1
fi

# NODE_ID=$(hostname)
NODE_ID=keycloak-$(head -c 4 /dev/urandom | od -An -t x | tr -d ' ' | base64)

exec /opt/keycloak/bin/standalone.sh $@ -Djboss.tx.node.id=$NODE_ID
exit $?
