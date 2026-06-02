# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

if (NOT WIN32)
    AddCIPackage(
        NAME ffmpeg
        PACKAGE FFmpeg
        VERSION 8.2-f16c3cc5aa
        REPO crueter-ci/FFmpeg-Qt
        MODULE)

    set(FFMPEG_DIR "${FFmpeg_SOURCE_DIR}")
endif()

AddQt(crueter-ci/Qt 6.11.1)

find_package(Qt6 REQUIRED COMPONENTS Widgets MultimediaWidgets Network)

message(STATUS "Qt directory: ${Qt6_DIR}")

add_executable(test_qt main.cpp)
target_link_libraries(test_qt Qt6::Widgets Qt6::MultimediaWidgets Qt6::Network)

set_target_properties(test_qt PROPERTIES
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_GUI_IDENTIFIER "dev.cpmutil.test_qt"
    MACOSX_BUNDLE_BUNDLE_NAME test_qt
    MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
)