#!/bin/sh -e

# SPDX-FileCopyrightText: Copyright 2025 crueter
# SPDX-License-Identifier: GPL-3.0-or-later

# Change CMakeModules to wherever you store external/Find modules
MODULES_DIR=CMakeModules
BASE_URL="https://git.crueter.xyz/CMake/CPMUtil/raw/branch/master"

# You may optionally choose to use CPMUtil.cmake releases when they are available
# These will also update tooling and documentation.
# OR use tags when they are available
wget -O "$MODULES_DIR/CPM.cmake" "$BASE_URL/CPM.cmake"
wget -O "$MODULES_DIR/CPMUtil.cmake" "$BASE_URL/CPMUtil.cmake"
