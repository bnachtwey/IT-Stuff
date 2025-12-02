#! /bin/bash

echo 'Fixing the skipping "N: Skipping acquire of configured file \'main/binary-i386/Packages\' as repository \'https://brave-browser-apt-release.s3.brave.com stable InRelease\' doesn´t support architecture \'i386\'"'

# due to https://community.brave.com/t/solved-linux-deb-install-gives-error-when-you-apt-update-a-repository/464626
# => To correct this you need to add the architecture parameterarch=amd64 in the deb command. E.g.
(
  set -x
  sudo sed -i 's#keyring.gpg]#keyring.gpg arch=amd64]#' /etc/apt/sources.list.d/brave-browser-release.list
)
  
