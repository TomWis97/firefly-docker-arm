#!/bin/bash
/etc/init.d/mysql start
cp "/var/firefly/env" .env
env | grep "^FIREFLY_CONFIG_" | sed 's/FIREFLY_CONFIG_//' >> .env

migrate_status=$(php artisan migrate:status -n --env=production)

if echo $migrate_status | grep -q "No migrations found";
then
    # The initial database setup needs to be done
    php artisan migrate --seed --env=production --force
else
    if echo $migrate_status | grep -q "^\|\s+N"
    then
        # One or more migrations still need to be run
        php artisan migrate --env=production --force
    fi
fi

$@
