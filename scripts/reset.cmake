#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(utils)

set(key discord-rpc)
parse_key(${key})

# TODO: This is a near exact copy of fetch.cmake
# TODO: Handle CI packages

# Get cache path.
get_cache_path()

# patch keys
compute_patch_key("${patches}" patch_key)

file(REMOVE_RECURSE ${pkg_cache_path})

get_url()
fetch_package("${pkg_url}" "${hash}" "${pkg_cache_path}" "${patch_key}")