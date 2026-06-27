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
if(DEFINED sha)
    string(SUBSTRING ${sha} 0 4 pkg_key)
else()
    set(pkg_key ${version})
endif()

string(TOLOWER ${package} lower_name)

# absolute dir
file(REAL_PATH ${CPM_SOURCE_CACHE}/${lower_name}/${pkg_key} path)
echo(${path})
