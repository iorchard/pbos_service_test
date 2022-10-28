#!/bin/bash
# read .env.sh
. .env.sh
# read openrc file
. $RC
# openstack API public endpoint ip address
PUBLIC_ENDPOINT=${OS_AUTH_URL%:*}
# admin project id
PROJECT_ID=$(openstack project show admin -c id -f value)
# get OS_TOKEN
OS_TOKEN=$(openstack token issue -c id -f value)
declare -A URLS=(
[KEYSTONE]=${PUBLIC_ENDPOINT}:5000/v3/services
[GLANCE]=${PUBLIC_ENDPOINT}:9292/v2/images
[PLACEMENT]=${PUBLIC_ENDPOINT}:8778/resource_providers
[NEUTRON]=${PUBLIC_ENDPOINT}:9696/v2.0/networks
[CINDER]=${PUBLIC_ENDPOINT}:8776/v3/${PROJECT_ID}/volumes
[NOVA]=${PUBLIC_ENDPOINT}:8774/v2.1/servers
[HORIZON]=${PUBLIC_ENDPOINT}:8800/dashboard/auth/login/
)
PASSCODE=200

i=1
for i in $(eval echo "{1..$ITERATION}"); do
  echo "# API REQUEST: $i"
  for key in "${!URLS[@]}";do
    scode=$(curl -s -H "X-Auth-Token: $OS_TOKEN" -w "%{http_code}" -o /dev/null -m 5 ${URLS[$key]})
    ts=$(date +%FT%T)
    [ "$PASSCODE" == "$scode" ] && msg="PASS" || msg="FAIL"
    printf "%10s\t%20s\t%10s\n" "$key" "$ts" "$msg($scode)"
  done
  sleep $SLEEP
  echo
  ((i++))
done
