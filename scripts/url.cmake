#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/)
include(utils)

parse_key(discord-rpc)

get_package_url_object(pkg_url)
echo("${pkg_url}")
