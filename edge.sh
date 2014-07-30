#!/bin/bash

compile_libpar2(){
  mkdir /tmp/libpar2
  wget -nv https://launchpad.net/libpar2/trunk/0.4/+download/libpar2-0.4.tar.gz -O - | tar --strip-components 1 -C /tmp/libpar2 -zxf - 
  wget -nv http://nzbget.net/files/libpar2-0.4-external-verification.patch -O /tmp/libpar2/libpar2-0.4-external-verification.patch
  cd /tmp/libpar2
  patch < libpar2-0.4-external-verification.patch
  ./configure
  make -j5
  make install
  cd /
  rm -rf cd /tmp/libpar2
}

if [[ -e /tmp/edge_installed ]]; then
  exit 0
fi

if [[ -n $EDGE ]]; then
  regex_version="\d*?\.\d*?"
  if [[ $EDGE =~ $regex_version ]]; then
    SVN="svn://svn.code.sf.net/p/nzbget/code/tags/${EDGE}"
    echo "Checking out version ${EDGE}"
  else
    SVN="-r ${EDGE} svn://svn.code.sf.net/p/nzbget/code/trunk"
    echo "Checking out revision $EDGE"
  fi
  # Remove nzbget
  dpkg --remove nzbget
  # Install build dependencies
  apt-get install -qy libncurses5-dev sigc++ libssl-dev libxml2-dev sigc++ build-essential subversion wget
  # Patch and compile libpar2
  compile_libpar2
  # Checkout the source code
  svn checkout ${SVN} /tmp/nzbget-source
  # Build and install the source code
  cd /tmp/nzbget-source
  ./configure --prefix=/usr
   make -j5
  make install
  # Do a cleanup
  cd /
  apt-get remove -qy libncurses5-dev sigc++ libssl-dev libxml2-dev sigc++ build-essential subversion wget
  rm -rf /tmp/nzbget-source
  # Mark edge as installed
  touch /tmp/edge_installed
  # Copy the config template to the webui path
  cp /usr/share/nzbget/nzbget.conf /usr/share/nzbget/webui/
fi
