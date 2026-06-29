#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(ScriptUtils)

parse_script_args(args)

get_cpmfile_content(cpmfile)
foreach(key ${args})
    parse_key("${key}")

    get_package_url_object(pkg_url)
    get_package_hash("${pkg_url}" pkg_hash)

    echo("-- ${key}")
    if (pkg_hash STREQUAL hash)
        echo("Hashes match")
    else()
        echo_error("Hash mismatch")
        echo_error("Expected: ${hash}")
        echo_error("Got:      ${pkg_hash}")

        modify_package("${object}" "${version}" "${pkg_hash}" new_object)

        # update cached cpmfile content
        string(JSON cpmfile SET "${cpmfile}" "${key}" "${new_object}")

        echo("Corrected hash for ${key}")
    endif()
endforeach()

# write cached cpmfile
get_cpmfile_path(file)
file(WRITE ${file} "${cpmfile}")
format_cpmfile()
