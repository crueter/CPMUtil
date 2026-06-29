#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

include(${CMAKE_CURRENT_LIST_DIR}/ScriptUtils.cmake)

function(usage)
    echo([=[
Usage: cpmutil.sh ls [-n] [PACKAGE]...

List all packages in the cpmfile.

Options:
    -n              Exclude CI packages from the list.
]=])
endfunction()

set(NO_ALL TRUE)
parse_script_args(args)

set(no_ci FALSE)
foreach(arg ${args})
    if(arg STREQUAL "-n")
        set(no_ci TRUE)
    endif()
endforeach()

list(FILTER args EXCLUDE REGEX "^-n")

if(args)
    set(keys ${args})
else()
    get_cpmfile_keys(keys)
endif()

foreach(key ${keys})
    if(no_ci)
        parse_key(${key})
        if(ci)
            continue()
        endif()
    endif()
    echo("${key}")
endforeach()
