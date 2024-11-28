#!/usr/bin/env bash
############################################LICENSE#################################################
# Copyright (C) 2024  Griefed
#
# This script is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
# USA
#
# The full license can be found at https:github.com/Griefed/ServerPackCreator/blob/main/LICENSE
############################################DESCRIPTION#################################################
#
# This script uses Jabba to download and install Java with the version required by the Minecraft version set in the
# variables.txt which was also shipped with this modpack. Should you want to use a different Java version with your
# server pack, change the RECOMMENDED_JAVA_VERSION. Likewise, you can change the vendor of the JDK to another one by
# changing JDK_VENDOR in your variables.txt
#
# Depending on which Minecraft version is used in this server pack, a different Java version may be installed.
#
# A list of available JDK versions and vendors can be found at https://github.com/Jabba-Team/index/blob/main/index.json
# Jabba is available at https://github.com/Jabba-Team/jabba
#
############################################NOTES#################################################
# Java Install script generated by ServerPackCreator 7.1.3.
# The template which was used in the generation of this script can be found at:
#   https://github.com/Griefed/ServerPackCreator/blob/7.1.3/serverpackcreator-api/src/main/resources/de/griefed/resources/server_files/default_java_template.sh
#
# The Linux scripts are intended to be run using bash (indicated by the `#!/usr/bin/env bash` at the top),
# i.e. by simply calling `./start.sh` or `bash start.sh`.
# Using any other method may work, but can also lead to unexpected behavior.
# Running the Linux scripts on MacOS has been done before, but is not tested by the developers of ServerPackCreator.
# Results may wary, no guarantees.
#
# Depending on which Minecraft version is used in this server pack, a different Java version may be installed.
#
# ATTENTION:
#   This script will NOT modify the JAVA_HOME variable for your user.

# commandAvailable(command)
# Check whether the command $1 is available for execution. Can be used in if-statements.
commandAvailable() {
  command -v "$1" > /dev/null 2>&1
}

# installJabba
# Downloads and installs Jabba, the software used to download and install Java for the Minecraft server.
installJabba() {
  echo "Downloading and installing jabba."
  if commandAvailable curl ; then
    curl -sL $JABBA_INSTALL_URL_SH | bash && . ~/.jabba/jabba.sh
  elif commandAvailable wget ; then
    wget -qO- $JABBA_INSTALL_URL_SH | bash && . ~/.jabba/jabba.sh
  else
    echo "[ERROR] wget or curl is required to install jabba."
    exit 1
  fi
  [ -s "$JABBA_HOME/jabba.sh" ] && source "$JABBA_HOME/jabba.sh"
}

# if ldd is not available, we may be on MacOS
if commandAvailable ldd ; then
  GBLIC_VERSION=$(ldd --version | awk '/ldd/{print $NF}')
  IFS="." read -ra GBLIC_SEMANTICS <<<"${GBLIC_VERSION}"

  # Older Linux systems aren't supported, sadly. This mainly affects Ubuntu 20 and Linux distributions from around that time
  # which use glibc versions older than 2.32 & 2.34.
  if [[ ${GBLIC_SEMANTICS[1]} -lt 32 ]];then
    echo "Jabba only supports systems with glibc 2.32 & 2.34 onward. You have $GBLIC_VERSION. Automated Java installation can not proceed."
    echo "DO NOT ATTEMPT TO UPDATE OR UPGRADE YOUR INSTALLED VERSION OF GLIBC! DOING SO MAY CORRUPT YOUR ENTIRE SYSTEM!"
    echo "Instead, consider upgrading to a newer version of your OS. Example: In case of Ubuntu 20 LTS, consider upgrading to 22 LTS or 24 LTS."
    exit 1
  fi
fi

if [[ ! -s "variables.txt" ]]; then
  echo "ERROR! variables.txt not present. Without it the server can not be installed, configured or started."
  exit 1
fi

source "variables.txt"

export JABBA_VERSION=${JABBA_INSTALL_VERSION}

if [[ -s ~/.jabba/jabba.sh ]];then
  source ~/.jabba/jabba.sh
elif ! commandAvailable jabba ; then
  echo "Automated Java installation requires a piece of Software called 'Jabba'."
  echo "Type 'I agree' if you agree to the installation of the aforementioned software."
  echo -n "Response: "
  read -r ANSWER

  if [[ "${ANSWER}" == "I agree" ]]; then
    installJabba
  else
    echo "User did not agree to Jabba installation. Aborting Java installation process."
    exit 1
  fi
fi

echo "Downloading and using Java ${JDK_VENDOR}@${RECOMMENDED_JAVA_VERSION}"
jabba install ${JDK_VENDOR}@${RECOMMENDED_JAVA_VERSION}
jabba use ${JDK_VENDOR}@${RECOMMENDED_JAVA_VERSION}

echo "Installation finished. Returning to start-script."