#!/usr/bin/env bash

COMPOSER="$(which composer)"

# Define the color scheme.
FG_C='\033[1;37m'
BG_C='\033[42m'
WBG_C='\033[43m'
EBG_C='\033[41m'
NO_C='\033[0m'

echo -e "\n\n"
echo -e "( )( ) (  ) (  _)(_   _)(  ) (   )( \_/ )"
echo -e "| || | /o \ | |    | |  /  \ | O  |\   / "
echo -e "( \/ )( __ )( )_   ( ) ( O  )( _ (  ( )  "
echo -e " \__/ /_\/_\/___\  /_\  \__/ /_\\_| |_|  "
echo -e "\n\n"

if [ -z "$COMPOSER" ]
then
  echo -e "${FG_C}${EBG_C} ERROR ${NO_C} Unable to locate composer. Make sure composer is installed before proceeding: 'which composer'"
  exit 1
fi

if [ $1 ] ; then
DEST_DIR=$1
else
  echo -e "${FG_C}${EBG_C} ERROR ${NO_C} Missing argument: No destination directory provided."
  exit 1
fi

if [ -d "$DEST_DIR" ]; then
  echo -e "${FG_C}${WBG_C} WARNING ${NO_C} $DEST_DIR already exists. Unable to install Vactory CMS in $DEST_DIR. Please delete $DEST_DIR and try again."
  echo -e "Try: rm -Rf $DEST_DIR"
  exit 5
fi
echo "-----------------------------------------------"
echo " Downloading Vactory CMS using composer ⏬ "
echo "-----------------------------------------------"
echo -e "${FG_C}${BG_C} EXECUTING ${NO_C} $COMPOSER create-project voidagency/vactory-decoupled-project ${DEST_DIR} --stability dev --no-interaction --remove-vcs --no-progress --prefer-dist\n\n"
php -d memory_limit=-1 $COMPOSER create-project voidagency/vactory-decoupled-project ${DEST_DIR} --stability dev --no-interaction --remove-vcs --prefer-dist

if [ $? -ne 0 ]; then
  echo -e "\n${FG_C}${EBG_C} ERROR ${NO_C} There was a problem building Vactory CMS using composer."
  echo -e "Please check your composer configuration and try again."
  exit 2
fi