#!/usr/bin/env bash

# Either add the following parameter values in the Jenkins job or directly add in the script
PROXY_HOST=${PROXY_HOST}
PROXY_PORT=${PROXY_PORT}
TARGET_URL=${TARGET_URL}
ZAP_PORT=${ZAP_PORT}

CONTAINER_ID=$(docker run -u zap -p $ZAP_PORT:$ZAP_PORT -d owasp/zap2docker-weekly zap.sh -daemon -port $ZAP_PORT -host 127.0.0.1 -config api.disablekey=true -config scanner.attackOnStart=true -config view.mode=attack -config connection.dnsTtlSuccessfulQueries=-1 -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true -config connection.proxyChain.enabled=true -config connection.proxyChain.hostName=$PROXY_HOST -config connection.proxyChain.port=$PROXY_PORT)

docker exec $CONTAINER_ID zap-cli -p $ZAP_PORT status -t 120 && docker exec $CONTAINER_ID zap-cli -p $ZAP_PORT open-url $TARGET_URL
docker exec $CONTAINER_ID zap-cli -p $ZAP_PORT spider $TARGET_URL
docker exec $CONTAINER_ID zap-cli -p $ZAP_PORT active-scan -r $TARGET_URL
docker exec $CONTAINER_ID zap-cli -p $ZAP_PORT alerts

# docker logs [container ID or name]
divider==================================================================
printf "\n"
printf "$divider"
printf "ZAP-daemon log output follows"
printf "$divider"
printf "\n"

docker logs $CONTAINER_ID
docker stop $CONTAINER_ID
