#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(ScriptUtils)

# arg parsing
parse_script_args(args)

list(LENGTH args arg_len)
if(arg_len GREATER 0)
    list(GET args 0 KEY)
endif()

if(arg_len GREATER 1)
    list(GET args 1 NEW_VERSION)
endif()

# checks
if (NOT KEY)
    fatal("You must provide a key")
endif()

if (NOT NEW_VERSION)
    fatal("You must provide a version")
endif()

# action
parse_key("${KEY}")

set(version ${NEW_VERSION})

get_package_url_object(pkg_url)
get_package_hash("${pkg_url}" pkg_hash)

modify_package("${object}" "${version}" "${pkg_hash}" new_object)

# update cached cpmfile content
string(JSON cpmfile SET "${cpmfile}" "${KEY}" "${new_object}")

# write cached cpmfile
get_cpmfile_path(file)
file(WRITE ${file} "${cpmfile}")
format_cpmfile()
