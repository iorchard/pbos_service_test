# global
# total iterations
ITERATION=50
# sleep seconds on every iteration
SLEEP=2

# OpenStack (probe.sh)
# openstack openrc file
RC="adminrc"

# DB (db_probe.sh)
DB_HOST="db.bkos.local"
DB_PORT=3306
DB_USERNAME="hatest"
DB_PASSWORD="<db_password>"
DATABASE="test"
DB_CACERT="$(pwd)/${DB_HOST}-ca-cert.pem"

# REDIS (redis_probe.sh)
REDIS_HOST="192.168.151.19"
REDIS_PORT=6379
REDIS_USERNAME="default"
REDIS_PASSWORD="<redis_password>"
