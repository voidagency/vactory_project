#!/usr/bin/env bash
# vim: noai:ts=4:sw=4:expandtab
# shellcheck source=/dev/null
# shellcheck disable=2009

# @todo: memcached vhost

version="1.0.0"

# ----------------------------------
# Global Config
# ----------------------------------
reset='\e[0m'
bash_version="${BASH_VERSION/.*}"
sys_locale="${LANG:-C}"
LC_ALL=C
LANG=C
shopt -s nocasematch

# ----------------------------------
# Colors
# ----------------------------------
NOCOLOR='\033[0m'
COLOR_ERROR='\033[0;31m'
COLOR_SUCCESS='\033[0;32m'
COLOR_LABEL='\033[0;37m'
COLOR_CYAN='\033[0;36m'

# clear the screen
clear

unset vecreset os architecture kernelrelease internalip externalip nameserver loadaverage APACHEVersion currentAPACHEVersion MYSQLVersion currentMYSQLVersion composerversion DRUSHVersion PHPVersion currentPHPVersion phpextesionlist PHPINIVALUE MYSQLCONFIGVALUE PORT80 PORT443 PORT22

# Define Variable vecreset
vecreset=$(tput sgr0)

# System Info
echo " "
echo -e "${COLOR_CYAN}+-------------------------+---------------------+"
echo -e "| System Info                                   |"
echo -e "+-------------------------+---------------------+${NOCOLOR}"
echo " "


# Check if connected to Internet or not
ping -c 1 google.com &> /dev/null && echo -e "${COLOR_LABEL}Internet :${NOCOLOR} $vecreset ${COLOR_SUCCESS}Connected${NOCOLOR}" || echo -e "{$COLOR_LABEL}Internet :${NOCOLOR} $vecreset ${COLOR_ERROR}Disconnected${NOCOLOR}"

# Check OS Type
os=$(uname -o)
echo -e "${COLOR_LABEL}Operating System Type :${NOCOLOR}" $vecreset $os

# Check OS Release Version and Name
cat /etc/os-release | grep 'NAME\|VERSION' | grep -v 'VERSION_ID' | grep -v 'PRETTY_NAME' > /tmp/osrelease
echo -n -e "${COLOR_LABEL}OS Name :${NOCOLOR}" $vecreset  && cat /tmp/osrelease | grep -v "VERSION" | cut -f2 -d\"
echo -n -e "${COLOR_LABEL}OS Version :${NOCOLOR}" $vecreset && cat /tmp/osrelease | grep -v "NAME" | cut -f2 -d\"

# Check Architecture
architecture=$(uname -m)
echo -e "${COLOR_LABEL}Architecture :${NOCOLOR}" $vecreset $architecture

# Check Kernel Release
kernelrelease=$(uname -r)
echo -e "${COLOR_LABEL}Kernel Release :${NOCOLOR}" $vecreset $kernelrelease

# Check hostname
echo -e "${COLOR_LABEL}Hostname :${NOCOLOR}" $vecreset $HOSTNAME

# Check Internal IP
internalip=$(hostname -I)
echo -e "${COLOR_LABEL}Internal IP :${NOCOLOR}" $vecreset $internalip

# Check External IP
externalip=$(curl -s ipecho.net/plain;echo)
echo -e "${COLOR_LABEL}External IP :${NOCOLOR} $vecreset "$externalip

# Check DNS
nameservers=$(cat /etc/resolv.conf | sed '1 d' | awk '{print $2}')
echo -e "${COLOR_LABEL}Name Servers :${NOCOLOR}" $vecreset $nameservers

# Check Logged In Users
who>/tmp/who
echo -e "${COLOR_LABEL}Logged In users :${NOCOLOR}" $vecreset && cat /tmp/who

# Check RAM and SWAP Usages
free -h | grep -v + > /tmp/ramcache
echo -e "${COLOR_LABEL}Ram Usages :${NOCOLOR}" $vecreset
cat /tmp/ramcache | grep -v "Swap"
echo -e "${COLOR_LABEL}Swap Usages :${NOCOLOR}" $vecreset
cat /tmp/ramcache | grep -v "Mem"

# Check Disk Usages
df -h| grep 'Filesystem\|/dev/sda*' > /tmp/diskusage
echo -e "${COLOR_LABEL}Disk Usages :${NOCOLOR}" $vecreset
cat /tmp/diskusage

# Check Load Average
loadaverage=$(top -n 1 -b | grep "load average:" | awk '{print $10 $11 $12}')
echo -e "${COLOR_LABEL}Load Average :${NOCOLOR}" $vecreset $loadaverage

# Check System Uptime
tecuptime=$(uptime | awk '{print $3,$4}' | cut -f1 -d,)
echo -e "${COLOR_LABEL}System Uptime Days/(HH:MM) :${NOCOLOR}" $vecreset $tecuptime

shift $(($OPTIND -1))

# System Tools
echo " "
echo -e "${COLOR_CYAN}+-------------------------+---------------------+"
echo -e "| System Tools                                   |"
echo -e "+-------------------------+---------------------+${NOCOLOR}"


if hash wget 2>/dev/null; then
    echo -e "${COLOR_LABEL}wget :${NOCOLOR} ${COLOR_SUCCESS} INSTALLED ${NOCOLOR}"
else
    echo -e "${COLOR_LABEL}wget :${NOCOLOR} ${COLOR_ERROR} MISSING ${NOCOLOR}"
fi

if hash tar 2>/dev/null; then
    echo -e "${COLOR_LABEL}tar :${NOCOLOR} ${COLOR_SUCCESS} INSTALLED ${NOCOLOR}"
else
    echo -e "${COLOR_LABEL}tar :${NOCOLOR} ${COLOR_ERROR} MISSING ${NOCOLOR}"
fi

if hash vim 2>/dev/null; then
    echo -e "${COLOR_LABEL}vim :${NOCOLOR} ${COLOR_SUCCESS} INSTALLED ${NOCOLOR}"
else
    echo -e "${COLOR_LABEL}vim :${NOCOLOR} ${COLOR_ERROR} MISSING ${NOCOLOR}"
fi

# System service - Apache
echo " "
echo -e "${COLOR_CYAN}+-------------------------+---------------------+"
echo -e "| Apache                                   |"
echo -e "+-------------------------+---------------------+${NOCOLOR}"
echo " "

APACHEVersion=$(httpd -v | grep "Server version:" |  awk '{print $3}')
currentAPACHEVersion=${APACHEVersion:7:${#APACHEVersion}}
currentAPACHEVersion=${currentAPACHEVersion:0:${#currentAPACHEVersion}-3}

if [ $(echo " $currentAPACHEVersion >= 2.4" | bc) -eq 1 ]; then
    echo -e "${COLOR_LABEL}Apache version:${NOCOLOR} ${COLOR_SUCCESS} ${APACHEVersion} ${NOCOLOR}"
else
    echo -e "${COLOR_LABEL}Apache version:${NOCOLOR} ${COLOR_ERROR} ${APACHEVersion} should be >= 2.4 ${NOCOLOR}"
fi

# System service - # Mysql
echo " "
echo -e "${COLOR_CYAN}+-------------------------+---------------------+"
echo -e "| MYSQL                                   |"
echo -e "+-------------------------+---------------------+${NOCOLOR}"
echo " "

MYSQLVersion=$(mysql --version|awk '{ print $5 }'|awk -F\, '{ print $1 }')
currentMYSQLVersion=${MYSQLVersion%.*.*}

if [ $(echo " $currentMYSQLVersion >= 5" | bc) -eq 1 ]; then
    echo -e "${COLOR_LABEL}MYSQL version:${NOCOLOR} ${COLOR_SUCCESS} ${MYSQLVersion} ${NOCOLOR}"
else
    echo -e "${COLOR_LABEL}MYSQL version:${NOCOLOR} ${COLOR_ERROR} ${MYSQLVersion} should be >= 5 ${NOCOLOR}"
fi

MYSQLCONFIGVALUE=$(mysql -N -e 'SELECT @@GLOBAL.max_allowed_packet;' |awk '{print $1}')
# 8192 kilobytes = 64 megabytes
if [ $(echo " $MYSQLCONFIGVALUE >= 8192" | bc) -eq 1 ]; then
    echo -e "${COLOR_LABEL}- max_allowed_packet:${NOCOLOR} ${COLOR_SUCCESS} ${MYSQLCONFIGVALUE} ${NOCOLOR}"
else
    echo -e "${COLOR_LABEL}- max_allowed_packet:${NOCOLOR} ${COLOR_ERROR} ${MYSQLCONFIGVALUE} should be >= 8192 kilobytes = 64 megabytes ${NOCOLOR}"
fi

# System service - PHP
echo " "
echo -e "${COLOR_CYAN}+-------------------------+---------------------+"
echo -e "| PHP                                   |"
echo -e "+-------------------------+---------------------+${NOCOLOR}"
echo " "

PHPVersion=$(php -r "echo PHP_VERSION;")
currentPHPVersion=${PHPVersion:0:1}

if [ $(echo " $currentPHPVersion >= 7" | bc) -eq 1 ]; then
    echo -e "${COLOR_LABEL}PHP version:${NOCOLOR} ${COLOR_SUCCESS} ${PHPVersion} ${NOCOLOR}"
else
    echo -e "${COLOR_LABEL}PHP version:${NOCOLOR} ${COLOR_ERROR} ${PHPVersion} should be >= 7 ${NOCOLOR}"
fi

# PHP extensions
declare -a phpextesionlist=("date" "dom" "filter" "gd" "hash" "fileinfo" "json" "pdo_mysql" "session" "SimpleXML" "SPL" "tokenizer" "xml" "openssl" "curl" "mbstring" "iconv")

echo -e "${COLOR_LABEL}PHP extensions:${NOCOLOR}"
for i in "${phpextesionlist[@]}"
do
   PHPEXTENSION=$(php -m | grep $i)
   if  ! [[ -z $PHPEXTENSION ]] ; then
     echo -e "- ${i} ${COLOR_SUCCESS} OK ${NOCOLOR}"
   else
      echo -e "- ${i} ${COLOR_ERROR} MISSING ${NOCOLOR}"
   fi
done

# PHP Parameters
echo -e "${COLOR_LABEL}PHP INI Parameters:${NOCOLOR}"

PHPINIVALUE=$(php -i | grep max_input_vars | awk '{print $3}')
if [ $(echo " $PHPINIVALUE >= 2000" | bc) -eq 1 ]; then
    echo -e "- max_input_vars: ${COLOR_SUCCESS} ${PHPINIVALUE} ${NOCOLOR}"
else
    echo -e "- max_input_vars: ${COLOR_ERROR} ${PHPINIVALUE} (should be >= 2000) ${NOCOLOR}"
fi

PHPINIVALUE=$(php -i | grep display_errors | awk '{print $3}')
if [ "$PHPINIVALUE" == "STDOUT" ]; then
    echo -e "- display_errors: ${COLOR_ERROR} On (should be Off) ${NOCOLOR}"
else
    echo -e "- display_errors: ${COLOR_SUCCESS} Off ${NOCOLOR}"
fi

PHPINIVALUE=$(php -i | grep "log_errors =>" | awk '{print $3}')
if [ "$PHPINIVALUE" == "On" ]; then
    echo -e "- log_errors: ${COLOR_SUCCESS} ${PHPINIVALUE} ${NOCOLOR}"
else
    echo -e "- log_errors: ${COLOR_ERROR} ${PHPINIVALUE} (should be On) ${NOCOLOR}"
fi

PHPINIVALUE=$(php -i | grep "allow_url_fopen =>" | awk '{print $3}')
if [ "$PHPINIVALUE" == "On" ]; then
    echo -e "- allow_url_fopen: ${COLOR_SUCCESS} ${PHPINIVALUE} ${NOCOLOR}"
else
    echo -e "- allow_url_fopen: ${COLOR_ERROR} ${PHPINIVALUE} (should be On) ${NOCOLOR}"
fi

PHPINIVALUE=$(php -i | grep "allow_url_include => " | awk '{print $3}')
if [ "$PHPINIVALUE" == "Off" ]; then
    echo -e "- allow_url_include: ${COLOR_SUCCESS} ${PHPINIVALUE} ${NOCOLOR}"
else
    echo -e "- allow_url_include: ${COLOR_ERROR} ${PHPINIVALUE} (should be Off) ${NOCOLOR}"
fi

PHPINIVALUE=$(php -i | grep "upload_max_filesize => " | awk '{print $3}')
PHPINIVALUESUB=${PHPINIVALUE:0:${#PHPINIVALUE}-1}
if [ $(echo " $PHPINIVALUESUB >= 128" | bc) -eq 1 ]; then
    echo -e "- upload_max_filesize: ${COLOR_SUCCESS} ${PHPINIVALUE} ${NOCOLOR}"
else
    echo -e "- upload_max_filesize: ${COLOR_ERROR} ${PHPINIVALUE} (should be at least >= 128) ${NOCOLOR}"
fi

PHPINIVALUE=$(php -i | grep "memory_limit => " | awk '{print $3}')
PHPINIVALUESUB=${PHPINIVALUE:0:${#PHPINIVALUE}-1}
if [ $(echo " $PHPINIVALUESUB >= 256" | bc) -eq 1 ]; then
    echo -e "- memory_limit: ${COLOR_SUCCESS} ${PHPINIVALUE} ${NOCOLOR}"
else
    echo -e "- memory_limit: ${COLOR_ERROR} ${PHPINIVALUE} (should be at least >= 256) ${NOCOLOR}"
fi

PHPINIVALUE=$(php -i | grep "max_execution_time => " | awk '{print $3}')
if [ $(echo " $PHPINIVALUE >= 180" | bc) -eq 1 ]; then
    echo -e "- max_execution_time: ${COLOR_SUCCESS} ${PHPINIVALUE} ${NOCOLOR}"
else
    echo -e "- max_execution_time: ${COLOR_ERROR} ${PHPINIVALUE} (should be at least >= 180) ${NOCOLOR}"
fi

PHPINIVALUE=$(php -i | grep "post_max_size => " | awk '{print $3}')
PHPINIVALUESUB=${PHPINIVALUE:0:${#PHPINIVALUE}-1}
if [ $(echo " $PHPINIVALUESUB >= 20" | bc) -eq 1 ]; then
    echo -e "- post_max_size: ${COLOR_SUCCESS} ${PHPINIVALUE} ${NOCOLOR}"
else
    echo -e "- post_max_size: ${COLOR_ERROR} ${PHPINIVALUE} (should be at least >= 20) ${NOCOLOR}"
fi


# Drupal Stuff.
echo " "
echo -e "${COLOR_CYAN}+-------------------------+---------------------+"
echo -e "| DRUPAL                                   |"
echo -e "+-------------------------+---------------------+${NOCOLOR}"
echo " "

if hash drush 2>/dev/null; then
    echo -e "${COLOR_LABEL}drush :${NOCOLOR} ${COLOR_SUCCESS} INSTALLED ${NOCOLOR}"
else
    echo -e "${COLOR_LABEL}drush :${NOCOLOR} ${COLOR_ERROR} MISSING ${NOCOLOR}"
fi

DRUSHVersion=$(drush --version |  awk '{print $4}')
DRUSHVersion=${DRUSHVersion:0:1}

if [ $(echo " $DRUSHVersion >= 8" | bc) -eq 1 ]; then
    echo -e "${COLOR_LABEL}Drush version:${NOCOLOR} ${COLOR_SUCCESS} ${DRUSHVersion} ${NOCOLOR}"
else
    echo -e "${COLOR_LABEL}Drush version:${NOCOLOR} ${COLOR_ERROR} ${DRUSHVersion} should be >= 8 ${NOCOLOR}"
fi

if hash composer 2>/dev/null; then
    echo -e "${COLOR_LABEL}composer :${NOCOLOR} ${COLOR_SUCCESS} INSTALLED ${NOCOLOR}"
else
    echo -e "${COLOR_LABEL}composer :${NOCOLOR} ${COLOR_ERROR} MISSING ${NOCOLOR}"
fi

composerversion=$(composer --version |  awk '{print $3}')

if [ "$composerversion" == "1.7.2" ]; then
    echo -e "${COLOR_LABEL}composer version:${NOCOLOR} ${COLOR_SUCCESS} ${composerversion} ${NOCOLOR}"
else
    echo -e "${COLOR_LABEL}composer version:${NOCOLOR} ${COLOR_ERROR} ${composerversion} should be 1.7.2 ${NOCOLOR}"
fi

# Check web services.
echo " "
echo -e "${COLOR_CYAN}+-------------------------+---------------------+"
echo -e "| Internet - Web Services                                   |"
echo -e "+-------------------------+---------------------+${NOCOLOR}"
echo " "

echo -e "- Checking ${COLOR_LABEL}packagist.org${NOCOLOR}" && ping -c 1 packagist.org &> /dev/null && echo -e "${COLOR_SUCCESS}OK${NOCOLOR}" || echo -e "${COLOR_ERROR}Blocked${NOCOLOR}"
echo -e "- Checking ${COLOR_LABEL}repo.packagist.org${NOCOLOR}" && ping -c 1 repo.packagist.org &> /dev/null && echo -e "${COLOR_SUCCESS}OK${NOCOLOR}" || echo -e "${COLOR_ERROR}Blocked${NOCOLOR}"
echo -e "- Checking ${COLOR_LABEL}api.github.com${NOCOLOR}" && ping -c 1 api.github.com &> /dev/null && echo -e "${COLOR_SUCCESS}OK${NOCOLOR}" || echo -e "${COLOR_ERROR}Blocked${NOCOLOR}"
echo -e "- Checking ${COLOR_LABEL}github.com${NOCOLOR}" && ping -c 1 github.com &> /dev/null && echo -e "${COLOR_SUCCESS}OK${NOCOLOR}" || echo -e "${COLOR_ERROR}Blocked${NOCOLOR}"
echo -e "- Checking ${COLOR_LABEL}gitlab.com${NOCOLOR}" && ping -c 1 gitlab.com &> /dev/null && echo -e "${COLOR_SUCCESS}OK${NOCOLOR}" || echo -e "${COLOR_ERROR}Blocked${NOCOLOR}"
echo -e "- Checking ${COLOR_LABEL}bitbucket.org${NOCOLOR}" && ping -c 1 bitbucket.org &> /dev/null && echo -e "${COLOR_SUCCESS}OK${NOCOLOR}" || echo -e "${COLOR_ERROR}Blocked${NOCOLOR}"
echo -e "- Checking ${COLOR_LABEL}packages.drupal.org${NOCOLOR}" && ping -c 1 packages.drupal.org &> /dev/null && echo -e "${COLOR_SUCCESS}OK${NOCOLOR}" || echo -e "${COLOR_ERROR}Blocked${NOCOLOR}"
echo -e "- Checking ${COLOR_LABEL}amazonaws.com${NOCOLOR}" && ping -c 1 amazonaws.com &> /dev/null && echo -e "${COLOR_SUCCESS}OK${NOCOLOR}" || echo -e "${COLOR_ERROR}Blocked${NOCOLOR}"
echo -e "- Checking ${COLOR_LABEL}void-factory.s3.amazonaws.com${NOCOLOR}" && ping -c 1 void-factory.s3.amazonaws.com &> /dev/null && echo -e "${COLOR_SUCCESS}OK${NOCOLOR}" || echo -e "${COLOR_ERROR}Blocked${NOCOLOR}"
echo -e "- Checking ${COLOR_LABEL}lapreprod.com${NOCOLOR}" && ping -c 1 lapreprod.com &> /dev/null && echo -e "${COLOR_SUCCESS}OK${NOCOLOR}" || echo -e "${COLOR_ERROR}Blocked${NOCOLOR}"

# Port check
echo " "
echo -e "${COLOR_CYAN}+-------------------------+---------------------+"
echo -e "| PORTS CHECK                                   |"
echo -e "+-------------------------+---------------------+${NOCOLOR}"
echo " "

PORT80=`lsof -Pi :80 -sTCP:LISTEN -t | head -1`
PORT443=`lsof -Pi :443 -sTCP:LISTEN -t | head -1`
PORT22=`lsof -Pi :22 -sTCP:LISTEN -t | head -1`

if  ! [ -z $PORT80 ] ; then
   echo -e "${COLOR_LABEL} - Checking port 80 :${NOCOLOR} ${COLOR_SUCCESS} OK ${NOCOLOR}"
  else
   echo -e "${COLOR_LABEL} - Checking port 80 :${NOCOLOR} ${COLOR_ERROR} ERROR ${NOCOLOR}"
fi

if  ! [ -z $PORT443 ] ; then
   echo -e "${COLOR_LABEL} - Checking port 433 :${NOCOLOR} ${COLOR_SUCCESS} OK ${NOCOLOR}"
  else
     echo -e "${COLOR_LABEL} - Checking port 443 :${NOCOLOR} ${COLOR_ERROR} ERROR ${NOCOLOR}"
fi

if  ! [ -z $PORT22 ] ; then
   echo -e "${COLOR_LABEL} - Checking port 22 :${NOCOLOR} ${COLOR_SUCCESS} OK ${NOCOLOR}"
  else
     echo -e "${COLOR_LABEL} - Checking port 22 :${NOCOLOR} ${COLOR_ERROR} ERROR ${NOCOLOR}"
fi

# Unset Variables
unset vecreset os architecture kernelrelease internalip externalip nameserver loadaverage APACHEVersion currentAPACHEVersion MYSQLVersion currentMYSQLVersion composerversion DRUSHVersion PHPVersion currentPHPVersion phpextesionlist PHPINIVALUE MYSQLCONFIGVALUE PORT80 PORT443 PORT22

# Remove Temporary Files
rm /tmp/osrelease /tmp/who /tmp/ramcache /tmp/diskusage
