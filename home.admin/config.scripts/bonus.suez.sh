#!/bin/bash

# https://github.com/prusnak/suez/commits/master
SUEZVERSION="e402edbddb45d8a53af346b8582243f4068ece6c"

# command info
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "-help" ]; then
  echo "config script to install, update or uninstall Suez"
  echo "bonus.suez.sh [on|off|menu|update]"
  echo "installs the version $SUEZVERSION by default"
  exit 1
fi

PGPsigner="prusnak"
PGPpubkeyLink="https://github.com/${PGPsigner}.gpg"
PGPpubkeyFingerprint="91F3B339B9A02A3D"

source /mnt/hdd/raspiblitz.conf

# show info menu
if [ "$1" = "menu" ]; then
  dialog --title " Info Suez" --msgbox "
Suez is a command line tool.
Type: 'suez' for the default channel visualization for LND
Type: 'suez --help' in the command line to see the usage options.
Readme: https://github.com/prusnak/suez#readme
" 10 75
  exit 0
fi

# install
if [ "$1" = "1" ] || [ "$1" = "on" ]; then
  echo "# INSTALL SUEZ"

  cd /home/bitcoin || exit 1

  # dependency
  sudo -u bitcoin curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py\
    | sudo -u bitcoin python -

  # download source code
  sudo -u bitcoin git clone https://github.com/prusnak/suez.git
  cd suez || exit 1
  sudo -u bitcoin git reset --hard $SUEZVERSION
  sudo -u bitcoin /home/admin/config.scripts/blitz.git-verify.sh \
   "${PGPsigner}" "${PGPpubkeyLink}" "${PGPpubkeyFingerprint}" || exit 1
  sudo -u bitcoin /home/bitcoin/.local/bin/poetry install

  echo "# Adding alias"
  sudo -u admin touch /home/admin/_aliases
  echo "alias suez='cd /home/bitcoin/suez && sudo -u bitcoin /home/bitcoin/.local/bin/poetry run ./suez'"\
   | sudo tee -a /home/admin/_aliases

  # setting value in raspi blitz config
  /home/admin/config.scripts/blitz.conf.sh set suez "on"

  echo "# To use the alias in /home/admin/_aliases:"
  echo "source /home/admin/_aliases"
  echo "# Type: 'suez' for the default channel visualization for LND"
  echo "# Type: 'suez --help' in the command line to see the usage options."
  echo "# Readme: https://github.com/prusnak/suez#readme"

  exit 0
fi

# switch off
if [ "$1" = "0" ] || [ "$1" = "off" ]; then

  echo "# REMOVING SUEZ"
  sudo rm -rf /home/bitcoin/suez
  echo "# OK, suez is removed."

  # setting value in raspi blitz config
  /home/admin/config.scripts/blitz.conf.sh set suez "off"

  exit 0

fi

# update
if [ "$1" = "update" ]; then
  echo "# UPDATE SUEZ"
  cd /home/bitcoin || exit 1
  # dependency
  sudo -u bitcoin curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py\
    | sudo -u bitcoin python -
  # download source code
  if [ -d suez ]; then
    sudo -u bitcoin git clone https://github.com/prusnak/suez.git
  fi
  cd suez || exit 1
  sudo -u bitcoin git pull
  sudo -u bitcoin /home/admin/config.scripts/blitz.git-verify.sh \
   "${PGPsigner}" "${PGPpubkeyLink}" "${PGPpubkeyFingerprint}" || exit 1
  sudo -u bitcoin /home/bitcoin/.local/bin/poetry install
  echo "# Updated to the latest in https://github.com/prusnak/suez/commits/master"
  exit 0
fi

echo "FAIL - Unknown Parameter $1"
exit 1