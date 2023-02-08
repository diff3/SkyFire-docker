#!/bin/sh

docker exec -i trinity-mariadb mysql -u root -ppwd < trinity.sql
