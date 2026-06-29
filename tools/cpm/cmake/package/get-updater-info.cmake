#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

include(${CMAKE_CURRENT_LIST_DIR}/../ScriptUtils.cmake)

function(usage)
    echo([=[
Usage: cpmutil.sh get-updater-info [PACKAGE]...

Output key git_host repo version for packages that can be updated.
Skips CI packages and packages with skip_updates set.
]=])
endfunction()

set(NO_CI TRUE)
parse_script_args(args)
if(args)
    set(keys ${args})
else()
    get_cpmfile_keys(keys)
endif()

foreach(key ${keys})
    parse_key(${key})

    if(ci OR skip_updates)
        continue()
    endif()

    string(JSON artifact_val ERROR_VARIABLE err GET "${object}" artifact)
    if(err OR NOT artifact_val)
        set(artifact_val "null")
    endif()

    echo("${key} ${git_host} ${repo} ${version} ${artifact_val}")
endforeach()
