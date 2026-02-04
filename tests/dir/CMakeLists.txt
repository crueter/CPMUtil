# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

# download opus
set(opus_repo "xiph/opus")
set(opus_host "github.com")
set(opus_commit "5ded705cf4ffa13702c78eebecea0fdb2f4ef0de")

set(opus_url "https://${opus_host}/${opus_repo}/archive/${opus_commit}.tar.gz")
set(opus_archive "${CMAKE_CURRENT_BINARY_DIR}/opus-${opus_commit}.tar.gz")
set(opus_dir "${CMAKE_CURRENT_BINARY_DIR}/opus-${opus_commit}")

if(NOT EXISTS "${opus_archive}")
    file(DOWNLOAD
        "${opus_url}"
        "${opus_archive}"
        SHOW_PROGRESS
        TIMEOUT 60)
endif()

if(NOT EXISTS "${opus_dir}")
    file(ARCHIVE_EXTRACT
        INPUT "${opus_archive}"
        DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")
endif()

# use opus_dir stuff
set(CPMUTIL_FORCE_BUNDLED ON)
set(Opus_CUSTOM_DIR "${opus_dir}" CACHE STRING "" FORCE)
set(OPUS_BUILD_SHARED_LIBRARY OFF)

AddJsonPackage(opus)

add_executable(test_opus main.c)
target_link_libraries(test_opus Opus::opus)