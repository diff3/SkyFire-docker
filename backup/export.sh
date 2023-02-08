#!/bin/sh

docker exec trinity-mariadb mysqldump -u root -ppwd --databases auth characters hotfixes world > trinity.sql
