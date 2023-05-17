#!/bin/bash
#
# This file is part of The BiTGApps Project

# Create BiTGApps
mkdir BiTGApps

# Clone Build Sources
git clone https://github.com/BiTGApps/BiTGApps BiTGApps

# Create Sources
mkdir BiTGApps/sources

# Clone Package Sources
git clone https://github.com/BiTGApps/arm-sources BiTGApps/sources/arm-sources
git clone https://github.com/BiTGApps/arm64-sources BiTGApps/sources/arm64-sources
git clone https://github.com/BiTGApps/common-sources BiTGApps/sources/common-sources

# Clone Additional Sources
git clone https://github.com/BiTGApps/addon-sources BiTGApps/sources/addon-sources
