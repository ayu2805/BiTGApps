#!/bin/bash
#
# This file is part of The BiTGApps Project

# Build BASIC Version
if [ "$VARIANT" == "BASIC" ]; then
  source core.sh
  exit 0
fi

# Build OMNI Version
if [ "$VARIANT" == "OMNI" ]; then
  source omni.sh
  exit 0
fi

# Build FULL Version
if [ "$VARIANT" == "FULL" ]; then
  source full.sh
  exit 0
fi

# Build Minified Version
if [ "$VARIANT" == "MINI" ]; then
  source minified.sh
  exit 0
fi