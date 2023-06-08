#!/bin/bash
#
# This file is part of The BiTGApps Project

# Build BASIC Version
if [ "$VARIANT" == "BASIC" ]; then
  source makescripts/core.sh
  exit 0
fi

# Build OMNI Version
if [ "$VARIANT" == "OMNI" ]; then
  source makescripts/omni.sh
  exit 0
fi

# Build FULL Version
if [ "$VARIANT" == "FULL" ]; then
  source makescripts/full.sh
  exit 0
fi

# Build Minified Version
if [ "$VARIANT" == "MINI" ]; then
  source makescripts/minified.sh
  exit 0
fi