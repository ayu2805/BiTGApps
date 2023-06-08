#!/bin/bash
#
# This file is part of The BiTGApps Project

# Create Sources
mkdir sources

# Clone Package Sources
read -r -p "Do you want to clone arm-sources? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    git clone https://github.com/BiTGApps/arm-sources sources/arm-sources
fi
git clone https://github.com/BiTGApps/arm64-sources sources/arm64-sources
git clone https://github.com/BiTGApps/common-sources sources/common-sources

# Clone Additional Sources
git clone https://github.com/BiTGApps/addon-sources sources/addon-sources
