#!/usr/bin/env bash

#Docs https://github.com/retspen/webvirtmgr/wiki/Install-WebVirtMgr
#https://github.com/retspen/webvirtmgr.wiki.git

echo "Please specify installation directory"
read directory

echo ""
echo "Install Main Components for WebVirtMgr"
apt-get install git python-pip python-libvirt python-libxml2 novnc nginx supervisor
echo ""
cd $directory
git pull
echo ""
echo "PIP install requrements"
pip install -r $directory/requirements.txt
echo ""
echo "Sync db and collectstatic"
$directory/manage.py syncdb
echo ""
$directory/manage.py collectstatic
echo ""
echo "Backup nginx default.conf"
mkdir /etc/nginx/backup
mv /etc/nginx/sites-available/default /etc/nginx/backup
echo "server {
    listen 80 default_server;

    server_name $hostname;
    access_log /var/log/nginx/webvirtmgr_access_log; 

    location /static/ {
        root $directory/webvirtmgr/webvirtmgr;
        expires max;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-for $proxy_add_x_forwarded_for;
        proxy_set_header Host $host:$server_port;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 600;
        proxy_read_timeout 600;
        proxy_send_timeout 600;
        client_max_body_size 1024M; # Set higher depending on your needs 
    }
}" > /etc/nginx/sites-available/default

echo "Set permissions to WebVirtMgr directory"
chown -R www-data:www-data $directory

echo "Configure WebVirtMgr"
echo "[program:webvirtmgr]
command=/usr/bin/python $directory/webvirtmgr/manage.py run_gunicorn -c $directory/webvirtmgr/conf/gunicorn.conf.py
directory=$directory/webvirtmgr
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/webvirtmgr.log
redirect_stderr=true
user=www-data

[program:webvirtmgr-console]
command=/usr/bin/python $directory/webvirtmgr/console/webvirtmgr-console
directory=$directory/webvirtmgr
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/webvirtmgr-console.log
redirect_stderr=true
user=www-data" > /etc/supervisor/conf.d/webvirtmgr.conf

service supervisor stop
service supervisor start


echo "### BEGIN INIT INFO
# Provides:          webvirtmgr
# Required-Start:    $local_fs $network
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: webvirtmgr
# Description:       webvirtmgt
### END INIT INFO

case $1 in
start)
    echo "Starting WebVirtMgr"
    /opt/webvirtmgr/manage.py runserver 127.0.0.1:8000 > /dev/null 2>&1 &
    ;;
stop)
    echo "Stoping WebVirtMgr"
    kill `ps ax | grep runserver | grep -v grep | awk '{print $1}' | tr '/\n' ' '`
    ;;
*)
    echo "Usage: test  {start|stop|restart}"
    exit 1
    ;;
esac
exit 0
" > /etc/init.d/webvirtmgr
chmod +x /etc/init.d/webvirtmgr

/etc/init.d/webvirtmgr start

















