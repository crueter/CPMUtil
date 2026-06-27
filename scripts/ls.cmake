#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/)
include(utils)

get_cpmfile_content(object)

string(JSON len LENGTH ${object})

math(EXPR last_index "${len} - 1")
foreach(i RANGE ${last_index})
    string(JSON key MEMBER ${object} ${i})
    echo("${key}")
endforeach()
