# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

set(BUILD_SHARED_LIBS OFF)

AddJsonPackage(zlib)

# ffmpeg fun

if (NOT APPLE)
    AddJsonPackage(openssl)
endif()

AddJsonPackage(ffmpeg)

set(FFMPEG_INCLUDE_DIR ${ffmpeg_SOURCE_DIR}/include)
set(FFMPEG_LIB_DIR ${ffmpeg_SOURCE_DIR}/lib)

add_library(ffmpeg INTERFACE)
set_target_properties(ffmpeg PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR})

foreach (LIB avformat avcodec avdevice avfilter avutil swresample swscale)
    message(STATUS "Adding library ${LIB}")
    add_library(${LIB} STATIC IMPORTED)
    set_target_properties(${LIB} PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR})

    if (UNIX)
        set_target_properties(${LIB} PROPERTIES
            IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/lib${LIB}.a)
    endif()

    add_library(FFmpeg::${LIB} ALIAS ${LIB})
    target_link_libraries(ffmpeg INTERFACE FFmpeg::${LIB})
endforeach()

add_library(FFmpeg::FFmpeg ALIAS ffmpeg)

# TODO(crueter): Implement this into the FFmpeg CI
if (UNIX AND NOT ANDROID)
    find_package(PkgConfig REQUIRED)
    if (NOT ANDROID)
        pkg_check_modules(LIBVA libva)
        pkg_check_modules(CUDA cuda)
        pkg_check_modules(FFNVCODEC ffnvcodec)
        pkg_check_modules(VDPAU vdpau)
    endif()

    if (NOT APPLE)
        pkg_check_modules(LIBDRM libdrm REQUIRED)
        list(APPEND FFmpeg_HWACCEL_LIBRARIES
            ${LIBDRM_LIBRARIES})
    endif()

    if(LIBVA_FOUND)
        find_package(X11 REQUIRED)
        pkg_check_modules(LIBVA-DRM libva-drm REQUIRED)
        pkg_check_modules(LIBVA-X11 libva-x11 REQUIRED)
        list(APPEND FFmpeg_HWACCEL_LIBRARIES
            ${X11_LIBRARIES}
            ${LIBVA-DRM_LIBRARIES}
            ${LIBVA-X11_LIBRARIES}
            ${LIBVA_LIBRARIES})
    endif()

    if (FFNVCODEC_FOUND)
        list(APPEND FFmpeg_HWACCEL_LIBRARIES ${FFNVCODEC_LIBRARIES})
        if (CUDA_FOUND)
            list(APPEND FFmpeg_HWACCEL_LIBRARIES ${CUDA_LIBRARIES})
        endif(CUDA_FOUND)
    endif()

    if (VDPAU_FOUND AND NOT APPLE)
        list(APPEND FFmpeg_HWACCEL_LIBRARIES ${VDPAU_LIBRARIES})
    endif()
endif()

if(APPLE)
    foreach(fw VideoToolbox CoreVideo CoreMedia CoreFoundation AudioToolbox Security)
        find_library(${fw}_LIBRARY ${fw} REQUIRED)
        list(APPEND FFmpeg_HWACCEL_LIBRARIES ${${fw}_LIBRARY})
    endforeach()

    list(APPEND FFmpeg_HWACCEL_LIBRARIES bz2)
endif()

add_executable(test_ffmpeg main.cpp)

# TODO(crueter): dunno why interface lib doesn't werk
target_link_libraries(test_ffmpeg PRIVATE
    FFmpeg::avformat
    FFmpeg::avcodec
    FFmpeg::avdevice
    FFmpeg::avfilter
    FFmpeg::avutil
    FFmpeg::swresample
    FFmpeg::swscale

    ZLIB::ZLIB

    ${FFmpeg_HWACCEL_LIBRARIES})

if (NOT APPLE)
    target_link_libraries(test_ffmpeg PRIVATE
        OpenSSL::SSL
        OpenSSL::Crypto)
endif()