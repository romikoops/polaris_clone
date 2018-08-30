#!/usr/bin/env bash
. /opt/elasticbeanstalk/support/envvars
DIR=/var/app/current
if [ "$WORKER_MODE" = "1" ]
  then
    if [ -f /var/run/shoryuken.pid ]
      then
        su -l -c "kill -USR1 `cat /var/run/shoryuken.pid`" root || echo "no process"
        su -l -c "rm -f /var/run/shoryuken.pid" root || echo "no file"
    fi
    su -l -c "cd $DIR && bundle exec shoryuken -d -R -C config/shoryuken.yml -P /var/run/shoryuken.pid -L log/shoryuken.log" root
fi
