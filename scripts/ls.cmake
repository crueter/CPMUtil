# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

#!/usr/bin/env -S cmake -P
cmake_minimum_required(VERSION 3.31)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/..)
set(CPMUTIL_ROOT ${CMAKE_CURRENT_LIST_DIR}/../tests)
include(CPMUtil)

macro(echo)
    string(REPLACE ";" " " message "${ARGN}")
    execute_process(COMMAND ${CMAKE_COMMAND} -E echo
        "${message}")
endmacro()

get_cpmfile_content(object)

string(JSON len LENGTH ${object})

set(keys "")
math(EXPR last_index "${len} - 1")
foreach(i RANGE ${last_index})
    string(JSON key MEMBER ${object} ${i})
    echo("${key}")
endforeach()
