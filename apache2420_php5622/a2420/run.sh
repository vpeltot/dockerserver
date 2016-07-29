# command return current host IP address ol local network
#ip route get 1 | awk '{print $NF;exit}'
HOST_LOCAL_IP_ADDR_IP4=$(ip route get 1 | awk '{print $NF;exit}')
export HOST_LOCAL_IP_ADDR_IP4

/etc/apache2/bin/apachectl restart

#$FPM_START_FILE restart
