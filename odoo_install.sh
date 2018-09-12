#!/bin/bash
################################################################################
# Script for installing Odoo V10 on Ubuntu 16.04, 15.04, 14.04 (could be used for other version too)
# Author: Yenthe Van Ginneken
#-------------------------------------------------------------------------------
# This script will install Odoo on your Ubuntu 14.04 server. It can install multiple Odoo instances
# in one Ubuntu because of the different xmlrpc_ports
#-------------------------------------------------------------------------------
# Make a new file:
# sudo nano odoo-install.sh
# Place this content in it and then make the file executable:
# sudo chmod +x odoo-install.sh
# Execute the script to install Odoo:
# ./odoo-install
################################################################################
 
##fixed parameters
#odoo
OE_USER="odoo"
OE_HOME="/$OE_USER"
OE_HOME_EXT="/$OE_USER/${OE_USER}-server"
#The default port where this Odoo instance will run under (provided you use the command -c in the terminal)
#Set to true if you want to install it, false if you don't need it or have it already installed.
INSTALL_WKHTMLTOPDF="True"
#Set the default Odoo port (you still have to use -c /etc/odoo-server.conf for example to use this.)
OE_PORT="8069"
#Choose the Odoo version which you want to install. For example: 10.0, 9.0, 8.0, 7.0 or saas-6. When using 'trunk' the master version will be installed.
#IMPORTANT! This script contains extra libraries that are specifically needed for Odoo 10.0
OE_VERSION="10.0"
# Set this to True if you want to install Odoo 10 Enterprise!
IS_ENTERPRISE="False"
#set the superadmin password
OE_SUPERADMIN="admin"
OE_CONFIG="${OE_USER}-server"

##
###  WKHTMLTOPDF download links
## === Ubuntu Trusty x64 & x32 === (for other distributions please replace these two links,
## in order to have correct version of wkhtmltox installed, for a danger note refer to 
## https://www.odoo.com/documentation/8.0/setup/install.html#deb ):
WKHTMLTOX_X64=https://downloads.wkhtmltopdf.org/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
WKHTMLTOX_X32=https://downloads.wkhtmltopdf.org/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-i386.deb

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
sudo apt-get update
sudo apt-get upgrade -y

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
echo -e "\n---- Install PostgreSQL Server ----"
sudo apt-get install postgresql -y

echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $OE_USER" 2> /dev/null || true

#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
echo -e "\n---- Install tool packages ----"
sudo apt-get install wget git python-pip gdebi-core -y
sudo apt-get install -y moreutils
sudo apt-get install -y \
             ca-certificates \
             curl \
             node-less \
             node-clean-css \
             python-pyinotify \
             python-renderpm

curl --silent https://bootstrap.pypa.io/get-pip.py | python

echo -e "\n---- Install python packages ----"
sudo apt-get install python-dateutil python-feedparser python-ldap python-libxslt1 python-lxml python-mako python-openid python-psycopg2 python-pybabel python-pychart python-pydot python-pyparsing python-reportlab python-simplejson python-tz python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt python-yaml python-zsi python-docutils python-psutil python-mock python-unittest2 python-jinja2 python-pypdf python-decorator python-requests python-passlib python-pil -y python-suds

echo -e "\n---- Install python libraries ----"
sudo pip install gdata psycogreen ofxparse XlsxWriter xlrd

echo -e "\n--- Install other required packages"
sudo apt-get install node-clean-css -y
sudo apt-get install node-less -y
sudo apt-get install python-gevent -y

#--------------------------------------------------
# Install Wkhtmltopdf if needed
#--------------------------------------------------
if [ $INSTALL_WKHTMLTOPDF = "True" ]; then
  echo -e "\n---- Install wkhtml and place shortcuts on correct place for ODOO 10 ----"
  #pick up correct one from x64 & x32 versions:
  if [ "`getconf LONG_BIT`" == "64" ];then
      _url=$WKHTMLTOX_X64
  else
      _url=$WKHTMLTOX_X32
  fi
  sudo wget $_url
  sudo gdebi --n `basename $_url`
  sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
  sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin
else
  echo "Wkhtmltopdf isn't installed due to the choice of the user!"
fi

apt-get install -y adduser node-less node-clean-css python python-dateutil python-decorator python-docutils python-feedparser python-imaging python-jinja2 python-ldap python-libxslt1 python-lxml python-mako python-mock python-openid python-passlib python-psutil python-psycopg2 python-babel python-pychart python-pydot python-pyparsing python-pypdf python-reportlab python-requests python-suds python-tz python-vatnumber python-vobject python-werkzeug python-xlwt python-yaml
apt-get install -y python-gevent python-simplejson
pip install "werkzeug<0.12" --upgrade
pip install psycogreen
apt-get install -y postgresql-server-dev-all python-dev  build-essential libxml2-dev libxslt1-dev
apt-get install -y python-dev build-essential libxml2-dev libxslt1-dev

     pip uninstall PIL || echo "PIL is not installed"
     if [[ "$OS_RELEASE" == "jessie" ]]
     then
         apt-get install libjpeg62-turbo-dev zlib1g-dev -y
     elif [[ "$OS_RELEASE" == "trusty" ]]
     then
         apt-get install libjpeg-dev zlib1g-dev -y
     else
         apt-get install libjpeg-dev zlib1g-dev -y
     fi
     # reinstall pillow
     pip install -I pillow
     # (from here https://github.com/odoo/odoo/issues/612 )
     
apt-get install -y npm
ln -s /usr/bin/nodejs /usr/bin/node
npm install -g less less-plugin-clean-css

     ### Deps for Odoo Saas Tool
     # TODO replace it with deb packages
     apt-get install -y libffi-dev libssl-dev
     pip install Boto
     pip install FileChunkIO
     pip install pysftp
     pip install rotate-backups
     pip install oauthlib
     pip install requests --upgrade
     
     
echo -e "\n---- Create ODOO system user ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER
#The user should also be added to the sudo'ers group.
sudo adduser $OE_USER sudo

echo -e "\n---- Create Log directory ----"
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER

#--------------------------------------------------
# Install ODOO
#--------------------------------------------------
echo -e "\n==== Installing ODOO Server ===="
sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/odoo/odoo $OE_HOME_EXT/

if [ $IS_ENTERPRISE = "True" ]; then
    # Odoo Enterprise install!
    echo -e "\n--- Create symlink for node"
    sudo ln -s /usr/bin/nodejs /usr/bin/node
    sudo su $OE_USER -c "mkdir $OE_HOME/enterprise"
    sudo su $OE_USER -c "mkdir $OE_HOME/enterprise/addons"

    GITHUB_RESPONSE=$(sudo git clone --depth 1 --branch 10.0 https://www.github.com/odoo/enterprise "$OE_HOME/enterprise/addons" 2>&1)
    while [[ $GITHUB_RESPONSE == *"Authentication"* ]]; do
        echo "------------------------WARNING------------------------------"
        echo "Your authentication with Github has failed! Please try again."
        printf "In order to clone and install the Odoo enterprise version you \nneed to be an offical Odoo partner and you need access to\nhttp://github.com/odoo/enterprise.\n"
        echo "TIP: Press ctrl+c to stop this script."
        echo "-------------------------------------------------------------"
        echo " "
        GITHUB_RESPONSE=$(sudo git clone --depth 1 --branch 10.0 https://www.github.com/odoo/enterprise "$OE_HOME/enterprise/addons" 2>&1)
    done

    echo -e "\n---- Added Enterprise code under $OE_HOME/enterprise/addons ----"
    echo -e "\n---- Installing Enterprise specific libraries ----"
    sudo pip install sudo
    sudo apt-get install nodejs npm
    sudo npm install -g less
    sudo npm install -g less-plugin-clean-css
fi

echo -e "\n---- Create custom module directory ----"
sudo su $OE_USER -c "mkdir $OE_HOME/custom"
sudo su $OE_USER -c "mkdir $OE_HOME/custom/addons"

echo -e "\n---- Setting permissions on home folder ----"
sudo chown -R $OE_USER:$OE_USER $OE_HOME/*

echo -e "* Create server config file"
sudo cp $OE_HOME_EXT/debian/odoo.conf /etc/${OE_CONFIG}.conf
sudo chown $OE_USER:$OE_USER /etc/${OE_CONFIG}.conf
sudo chmod 640 /etc/${OE_CONFIG}.conf

echo -e "* Change server config file"
sudo sed -i s/"db_user = .*"/"db_user = $OE_USER"/g /etc/${OE_CONFIG}.conf
sudo sed -i s/"; admin_passwd.*"/"admin_passwd = $OE_SUPERADMIN"/g /etc/${OE_CONFIG}.conf
sudo su root -c "echo '[options]' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "echo 'logfile = /var/log/$OE_USER/$OE_CONFIG$1.log' >> /etc/${OE_CONFIG}.conf"
if [  $IS_ENTERPRISE = "True" ]; then
    sudo su root -c "echo 'addons_path=$OE_HOME/enterprise/addons,$OE_HOME_EXT/addons' >> /etc/${OE_CONFIG}.conf"
else
    sudo su root -c "echo 'addons_path=$OE_HOME_EXT/addons,$OE_HOME/custom/addons', >> /etc/${OE_CONFIG}.conf"
fi

echo -e "* Create startup file"
sudo su root -c "echo '#!/bin/sh' >> $OE_HOME_EXT/start.sh"
sudo su root -c "echo 'sudo -u $OE_USER $OE_HOME_EXT/openerp-server --config=/etc/${OE_CONFIG}.conf' >> $OE_HOME_EXT/start.sh"
sudo chmod 755 $OE_HOME_EXT/start.sh


cd  $OE_HOME/custom
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/web.git OCA/web")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/event.git OCA/event")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/website.git OCA/website")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/account-financial-reporting.git OCA/account-financial-reporting")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/account-financial-tools.git OCA/account-financial-tools")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/partner-contact.git OCA/partner-contact")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/hr.git OCA/hr")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/pos.git OCA/pos")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/commission.git OCA/commission")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/server-tools.git OCA/server-tools")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/reporting-engine.git OCA/reporting-engine")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/rma.git OCA/rma")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/contract.git OCA/contract")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/sale-workflow.git OCA/sale-workflow")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/bank-payment.git OCA/bank-payment")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/bank-statement-import.git OCA/bank-statement-import")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/bank-statement-reconcile.git OCA/bank-statement-reconcile")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/account-invoicing.git OCA/account-invoicing")
     REPOS=( "${REPOS[@]}" "https://github.com/OCA/account-closing.git OCA/account-closing")
     REPOS=( "${REPOS[@]}" "https://github.com/it-projects-llc/e-commerce.git it-projects-llc/e-commerce")
     REPOS=( "${REPOS[@]}" "https://github.com/it-projects-llc/pos-addons.git it-projects-llc/pos-addons")
     REPOS=( "${REPOS[@]}" "https://github.com/it-projects-llc/access-addons.git it-projects-llc/access-addons")
     REPOS=( "${REPOS[@]}" "https://github.com/it-projects-llc/website-addons.git it-projects-llc/website-addons")
     REPOS=( "${REPOS[@]}" "https://github.com/it-projects-llc/misc-addons.git it-projects-llc/misc-addons")
     REPOS=( "${REPOS[@]}" "https://github.com/it-projects-llc/mail-addons.git it-projects-llc/mail-addons")
     REPOS=( "${REPOS[@]}" "https://github.com/it-projects-llc/odoo-saas-tools.git it-projects-llc/odoo-saas-tools")
     REPOS=( "${REPOS[@]}" "https://github.com/it-projects-llc/odoo-telegram.git it-projects-llc/odoo-telegram")
     
     if [[ "${REPOS}" != "" ]]
 then
     apt-get install -y git
 fi

 for r in "${REPOS[@]}"
 do
     eval "git clone --depth=1 -b ${OE_VERSION} $r" || echo "Cannot clone: git clone -b ${OE_VERSION} $r"
 done
 
 if [[ "${REPOS}" != "" ]]
 then
     chown -R ${OE_USER}:${OE_USER} $OE_HOME/custom || true
 fi
 
 ADDONS_PATH=`ls -d1 $ADDONS_DIR/*/* | tr '\n' ','`

#--------------------------------------------------
# Adding ODOO as a deamon (initscript)
#--------------------------------------------------

echo -e "* Create init file"
cat <<EOF > ~/$OE_CONFIG
#!/bin/sh
### BEGIN INIT INFO
# Provides: $OE_CONFIG
# Required-Start: \$remote_fs \$syslog
# Required-Stop: \$remote_fs \$syslog
# Should-Start: \$network
# Should-Stop: \$network
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Enterprise Business Applications
# Description: ODOO Business Applications
### END INIT INFO
PATH=/bin:/sbin:/usr/bin
DAEMON=$OE_HOME_EXT/odoo-bin
NAME=$OE_CONFIG
DESC=$OE_CONFIG
# Specify the user name (Default: odoo).
USER=$OE_USER
# Specify an alternate config file (Default: /etc/openerp-server.conf).
CONFIGFILE="/etc/${OE_CONFIG}.conf"
# pidfile
PIDFILE=/var/run/\${NAME}.pid
# Additional options that are passed to the Daemon.
DAEMON_OPTS="-c \$CONFIGFILE"
[ -x \$DAEMON ] || exit 0
[ -f \$CONFIGFILE ] || exit 0
checkpid() {
[ -f \$PIDFILE ] || return 1
pid=\`cat \$PIDFILE\`
[ -d /proc/\$pid ] && return 0
return 1
}
case "\${1}" in
start)
echo -n "Starting \${DESC}: "
start-stop-daemon --start --quiet --pidfile \$PIDFILE \
--chuid \$USER --background --make-pidfile \
--exec \$DAEMON -- \$DAEMON_OPTS
echo "\${NAME}."
;;
stop)
echo -n "Stopping \${DESC}: "
start-stop-daemon --stop --quiet --pidfile \$PIDFILE \
--oknodo
echo "\${NAME}."
;;
restart|force-reload)
echo -n "Restarting \${DESC}: "
start-stop-daemon --stop --quiet --pidfile \$PIDFILE \
--oknodo
sleep 1
start-stop-daemon --start --quiet --pidfile \$PIDFILE \
--chuid \$USER --background --make-pidfile \
--exec \$DAEMON -- \$DAEMON_OPTS
echo "\${NAME}."
;;
*)
N=/etc/init.d/\$NAME
echo "Usage: \$NAME {start|stop|restart|force-reload}" >&2
exit 1
;;
esac
exit 0
EOF

echo -e "* Security Init File"
sudo mv ~/$OE_CONFIG /etc/init.d/$OE_CONFIG
sudo chmod 755 /etc/init.d/$OE_CONFIG
sudo chown root: /etc/init.d/$OE_CONFIG

echo -e "* Change default xmlrpc port"
sudo su root -c "echo 'xmlrpc_port = $OE_PORT' >> /etc/${OE_CONFIG}.conf"

echo -e "* Start ODOO on Startup"
sudo update-rc.d $OE_CONFIG defaults

echo -e "* Starting Odoo Service"
sudo su root -c "/etc/init.d/$OE_CONFIG start"
echo "-----------------------------------------------------------"
echo "Done! The Odoo server is up and running. Specifications:"
echo "Port: $OE_PORT"
echo "User service: $OE_USER"
echo "User PostgreSQL: $OE_USER"
echo "Code location: $OE_USER"
echo "Addons folder: $OE_USER/$OE_CONFIG/addons/"
echo "Start Odoo service: sudo service $OE_CONFIG start"
echo "Stop Odoo service: sudo service $OE_CONFIG stop"
echo "Restart Odoo service: sudo service $OE_CONFIG restart"
echo "-----------------------------------------------------------"
