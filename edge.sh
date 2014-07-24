#!/bin/bash

if [[ -e /tmp/edge_installed ]]; then
  exit 0
fi

if [[ -n $EDGE ]]; then
  if [[ $EDGE == 1 ]]; then
    SVN="svn://svn.code.sf.net/p/nzbget/code/trunk"
  else
    SVN="svn://svn.code.sf.net/p/nzbget/code/tags/${EDGE}"
  fi
  # Install build dependencies
  apt-get install -qy libncurses5-dev sigc++ libpar2-dev libssl-dev libgnutls-dev libxml2-dev sigc++ build-essential subversion
  # Checkout the source code
  svn checkout ${SVN} /tmp/nzbget-source
  # Build and install the source code
  cd /tmp/nzbget-source
  ./configure
  make
  make install
  # Do a cleanup
  cd /
  apt-get remove -qy libncurses5-dev sigc++ libpar2-dev libssl-dev libgnutls-dev libxml2-dev sigc++ build-essential subversion
  rm -rf /tmp/nzbget-source
  # Mark edge as installed
  touch /tmp/edge_installed
fi
