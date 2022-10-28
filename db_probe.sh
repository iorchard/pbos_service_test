#!/bin/bash
HOST=$DB_HOST
PORT=$DB_PORT
USERNAME=$DB_USERNAME
PASSWORD=$DB_PASSWORD
CACERT=$DB_CACERT

TABLE="test_table"
mysql --host="$HOST" --port=$PORT --user="$USERNAME" --password="$PASSWORD" \
    --ssl-ca="${CACERT}" --database="$DATABASE" \
    --execute="DROP TABLE IF EXISTS $TABLE"

mysql --host="$HOST" --port=$PORT --user="$USERNAME" --password="$PASSWORD" \
    --ssl-ca="${CACERT}" --database="$DATABASE" \
    --execute="CREATE TABLE IF NOT EXISTS $TABLE (id INT, str VARCHAR(10))"

i=1
for i in $(eval echo "{1..$ITERATION}"); do
  echo "# BEGINNING OF TRANSACTION NUMBER $i"
  ID=$RANDOM
  STR=$(echo $ID|md5sum|head -c 8)
  echo "> Insert the data ($ID, $STR) "
  mysql --host="$HOST" --port=$PORT --user="$USERNAME" --password="$PASSWORD" \
      --ssl-ca="${CACERT}" --database="$DATABASE" \
      --silent --skip-column-names \
      --execute="INSERT INTO $TABLE VALUES($ID, '$STR');SHOW VARIABLES LIKE 'wsrep_node_name';"
  
  echo -n "> Get the data: "
  mysql --host="$HOST" --port=$PORT --user="$USERNAME" --password="$PASSWORD" \
      --ssl-ca="${CACERT}" --database="$DATABASE" \
      --silent --skip-column-names \
      --execute="SELECT id FROM $TABLE WHERE id=$ID;SHOW VARIABLES LIKE 'wsrep_node_name';"
  
  NEWID=$RANDOM
  NEWSTR=$(echo $NEWID|md5sum|head -c 8)
  echo "> Update the data ($NEWID, $NEWSTR) "
  mysql --host="$HOST" --port=$PORT --user="$USERNAME" --password="$PASSWORD" \
      --ssl-ca="${CACERT}" --database="$DATABASE" \
      --silent --skip-column-names \
      --execute="UPDATE $TABLE SET id=$NEWID, str='$NEWSTR' WHERE id=$ID;SHOW VARIABLES LIKE 'wsrep_node_name';"
  
  echo -n "> Get the data: "
  mysql --host="$HOST" --port=$PORT --user="$USERNAME" --password="$PASSWORD" \
      --ssl-ca="${CACERT}" --database="$DATABASE" \
      --silent --skip-column-names \
      --execute="SELECT id FROM $TABLE WHERE id=$NEWID;SHOW VARIABLES LIKE 'wsrep_node_name';"
  
  echo "> Delete the data: "
  mysql --host="$HOST" --port=$PORT --user="$USERNAME" --password="$PASSWORD" \
      --ssl-ca="${CACERT}" --database="$DATABASE" \
      --silent --skip-column-names \
      --execute="DELETE FROM $TABLE WHERE id=$NEWID;SHOW VARIABLES LIKE 'wsrep_node_name';"
  
  echo -n "> Count the data: "
  mysql --host="$HOST" --port=$PORT --user="$USERNAME" --password="$PASSWORD" \
      --ssl-ca="${CACERT}" --database="$DATABASE" \
      --silent --skip-column-names \
      --execute="SELECT COUNT(*) FROM $TABLE WHERE id=$NEWID;SHOW VARIABLES LIKE 'wsrep_node_name';"
  echo "# END OF TRANSACTION NUMBER $i"
  sleep $SLEEP
  ((i++))
done
