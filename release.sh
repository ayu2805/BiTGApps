#!/bin/bash
#
# This file is part of The BiTGApps Project

github-release upload \
  --owner "BiTGApps" \
  --repo "BiTGApps-Release" \
  --token "$TOKEN" \
  --tag "${RELEASE}" \
  --release-name "BiTGApps ${RELEASE}" \
  "out/GApps/$1/BiTGApps-$1-13.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/$1/BiTGApps-$1-12.1.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/$1/BiTGApps-$1-12.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/$1/BiTGApps-$1-11.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/$1/BiTGApps-$1-10.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/$1/BiTGApps-$1-9.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/$1/BiTGApps-$1-8.1.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/$1/BiTGApps-$1-8.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/$1/BiTGApps-$1-7.1.2-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/$1/BiTGApps-$1-7.1.1-${RELEASE}-${VARIANT}.zip"
