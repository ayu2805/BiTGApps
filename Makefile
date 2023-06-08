#
# Copyright (C) 2015-2020 The Open GApps Team
# Copyright (C) 2018-2023 The BiTGApps Project
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#

TOPDIR := .
BUILD_SYSTEM := $(TOPDIR)
BUILD_GAPPS := $(BUILD_SYSTEM)/makescripts/build.sh
APIS := 24 25 26 27 28 29 30 31 32 33
PLATFORMS := arm arm64
LOWEST_API_arm := 24
LOWEST_API_arm64 := 24
BUILDDIR := $(TOPDIR)/build
OUTDIR := $(TOPDIR)/out

define make-gapps
# We first define 'all' so that this is the primary make target
all:: $1

# It will execute the build script with the platform, api as parameter,
# meanwhile ensuring the minimum api for the platform that is selected
$1:
	$(platform = $(firstword $(subst -, ,$1)))
	$(api = $(word 2, $(subst -, ,$1)))
	@if [ "$(api)" -ge "$(LOWEST_API_$(platform))" ] ; then\
		$(BUILD_GAPPS) $(platform) $(api) 2>&1;\
	else\
		echo "Illegal combination of Platform and API";\
	fi;\
	exit 0
endef

$(foreach platform,$(PLATFORMS),\
$(foreach api,$(APIS),\
$(eval $(call make-gapps,$(platform)-$(api)))\
))

clean:
	@-rm -fr "$(BUILDDIR)"
	@-rm -fr "$(OUTDIR)"
	@echo 'Build & Output directory removed'
