#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(utils)

parse_key(discord-rpc)

# Guh.
get_cache_path()

file(REAL_PATH ${pkg_cache_path} abs_path)
echo("${abs_path}")