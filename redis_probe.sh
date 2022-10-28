#!/bin/bash
HOST="192.168.151.19"
PORT=6379
USERNAME="default"
PASSWORD="A2hfosdf@8632"
# total iterations
ITERATION=50
# sleep seconds on every iteration
SLEEP=2

#
# Do Not Edit below!
#
export REDISCLI_AUTH="$PASSWORD"

i=1
for i in $(eval echo "{1..$ITERATION}"); do
  echo "# BEGINNING OF TRANSACTION NUMBER $i"
  KEY=$RANDOM
  VAL=$(echo $KEY|md5sum|head -c 8)
  echo -n "> Set the key $KEY to hold the value $VAL: "
  redis-cli -h $HOST -p $PORT --user $USERNAME SET $KEY $VAL
  
  echo -n "> Get the key value: "
  GETVAL=$(redis-cli -h $HOST -p $PORT --user $USERNAME GET $KEY)
  [[ "$VAL" = "$GETVAL" ]] && echo $GETVAL || exit 1 

  VAL=$(echo $RANDOM|md5sum|head -c 8)
  echo -n "> Update the key $KEY to the new value $VAL: "
  redis-cli -h $HOST -p $PORT --user $USERNAME SET $KEY $VAL
  
  echo -n "> Get the key value: "
  GETVAL=$(redis-cli -h $HOST -p $PORT --user $USERNAME GET $KEY)
  [[ "$VAL" = "$GETVAL" ]] && echo $GETVAL || exit 1
  
  echo -n "> Delete the key: "
  redis-cli -h $HOST -p $PORT --user $USERNAME DEL $KEY
  
  echo -n "> Get the deleted key (should return nil): "
  redis-cli -h $HOST -p $PORT --user $USERNAME GET $KEY

  echo "# END OF TRANSACTION NUMBER $i"
  sleep $SLEEP
  ((i++))
done
