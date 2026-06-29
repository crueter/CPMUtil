#!/usr/bin/env -S cmake -P

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

cmake_minimum_required(VERSION 3.31)

include(./ScriptUtils.cmake)

get_cpmfile_keys(keys)

foreach(key ${keys})
    echo("${key}")
endforeach()
