# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

#!/usr/bin/env -S cmake -P
cmake_minimum_required(VERSION 3.31)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../)
set(CPMUTIL_ROOT ${CMAKE_CURRENT_LIST_DIR}/../tests)
include(CPMUtil)

get_json_object(discord-rpc)
set(JSON_NAME discord-rpc)
parse_object(${object})

macro(echo)
    string(REPLACE ";" " " message "${ARGN}")
    execute_process(COMMAND ${CMAKE_COMMAND} -E echo
        "${message}")
endmacro()

# TODO: Move this to a util function.
if(NOT DEFINED git_host)
    set(git_host github.com)
endif()

if(DEFINED url)
    set(pkg_url ${pkg_url})
elseif(DEFINED repo)
    set(pkg_git_url https://${git_host}/${repo})

    if(DEFINED sha)
        set(pkg_url "${pkg_git_url}/archive/${sha}.tar.gz")
    elseif(DEFINED tag)
        set(tag "${tags}")
        if(DEFINED artifact)
            set(pkg_url
                "${pkg_git_url}/releases/download/${tag}/${artifact}")
        else()
            set(pkg_url
                "${pkg_git_url}/archive/refs/tags/${tag}.tar.gz")
        endif()
    endif()
else()
    cpm_utils_message(FATAL_ERROR
        "${package}: No URL or repository defined")
endif()

echo(${pkg_url})
