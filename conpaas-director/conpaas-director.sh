#!/bin/bash
TMPFILE=$(mktemp)
ATTEMPTS=5
while [ ${ATTEMPTS} -gt 0 ]; do
  ATTEMPTS=$((${ATTEMPTS}-1))
  curl --connect-timeout 1 -sf http://169.254.169.254/openstack/2012-08-10/user_data\
    > ${TMPFILE} 2>/dev/null
  if [ $? -eq 0 ]; then
    break
  fi
  sleep 1
done
if [ -e "${TMPFILE}" ]; then
    . ${TMPFILE}
fi
rm -f ${TMPFILE}


: ${HOME:="/root"}
: ${DRIVER:="openstack"}
: ${HOST:=""}
: ${USER:="conpaas"}
: ${PASSWORD:=""}
: ${SECGROUP:="conpaas-secgroup"}
: ${KEYNAME:="conpaas-keypair"}
: ${SIZE_ID:="m1.small"}
: ${IMAGE_ID:=""}

: ${CPS_USERNAME:="test"}
: ${CPS_PASSWORD:="password"}
: ${EMAIL:="test@email"}


: ${IP_ADDRESS:="$(ip addr show | perl -ne 'print "$1\n" if /inet ([\d.]+).*scope global/' | grep "$IP_PREFIX" | head -1)"}
: ${DIRECTOR_URL:="https://${IP_ADDRESS}:5555"}
#: ${CRS_URL:="http://${IP_ADDRESS}:56789"}

sed -i "/^logfile\s*=/s%=.*$%= /var/log/apache2/cpsfrontend-error.log%" /etc/cpsdirector/main.ini
sed -i "/^const DIRECTOR_URL =/s%=.*$%= '${DIRECTOR_URL}';%" /var/www/config.php
sed -i "/^DIRECTOR_URL =/s%=.*$%= ${DIRECTOR_URL}%" /etc/cpsdirector/director.cfg

sed -i "s|^\(# director_url\s*=\s*\).*$|director_url = ${DIRECTOR_URL}|" /root/.conpaas/cps-tools.conf
sed -i "s|^\(# username\s*=\s*\).*$|username = ${CPS_USERNAME}|" /root/.conpaas/cps-tools.conf
sed -i "s|^\(# password\s*=\s*\).*$|password = ${CPS_PASSWORD}|" /root/.conpaas/cps-tools.conf

cd ..
rm -rf cps-tools*
# sqlite3 /etc/cpsdirector/director.db 'update user set credit=999999'



sed -i -e"/^\[iaas\]/,/^\[.*\]/{/^DRIVER\s*=.*/d}" -e"/^\[iaas\]/aDRIVER = ${DRIVER}" /etc/cpsdirector/director.cfg
sed -i -e"/^\[iaas\]/,/^\[.*\]/{/^HOST\s*=.*/d}" -e"/^\[iaas\]/aHOST = ${HOST}" /etc/cpsdirector/director.cfg
sed -i -e"/^\[iaas\]/,/^\[.*\]/{/^HOST\s*=.*/d}" -e"/^\[iaas\]/aUSER = ${USER}" /etc/cpsdirector/director.cfg
sed -i -e"/^\[iaas\]/,/^\[.*\]/{/^HOST\s*=.*/d}" -e"/^\[iaas\]/aPASSWORD = ${PASSWORD}" /etc/cpsdirector/director.cfg
sed -i -e"/^\[iaas\]/,/^\[.*\]/{/^HOST\s*=.*/d}" -e"/^\[iaas\]/aSECGROUP = ${SECGROUP}" /etc/cpsdirector/director.cfg
sed -i -e"/^\[iaas\]/,/^\[.*\]/{/^HOST\s*=.*/d}" -e"/^\[iaas\]/aSIZE_ID = ${SIZE_ID}" /etc/cpsdirector/director.cfg
sed -i -e"/^\[iaas\]/,/^\[.*\]/{/^IMAGE_ID\s*=.*/d}" -e"/^\[iaas\]/aIMAGE_ID = ${IMAGE_ID}" /etc/cpsdirector/director.cfg

echo "ServerName ${IP_ADDRESS}" > /etc/apache2/conf-available/servername.conf
a2enconf servername
echo ${IP_ADDRESS} | cpsconf.py

# export PYTHON_EGG_CACHE="/tmp/director-eggcache"
service apache2 start

cpsadduser.py ${EMAIL} ${CPS_USERNAME} ${CPS_PASSWORD}
cps-user get_certificate
# cpsclient.py credentials ${DIRECTOR_URL} ${CPS_USERNAME} ${CPS_PASSWORD}
