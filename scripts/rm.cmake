#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/)
include(utils)

# Remove key

get_cpmfile_content(object)

# TODO: error handling
string(JSON new_object REMOVE "${object}" discord-rpc)

get_cpmfile_path(file)
file(WRITE ${file} "${new_object}")
format_cpmfile()