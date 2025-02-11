cmake_minimum_required(VERSION 3.15)
project(sonic-pi-api VERSION 0.0.0.1)

# Define root directories
set(API_ROOT "${CMAKE_CURRENT_LIST_DIR}")
set(VENDOR_DIR "${API_ROOT}/vendor")

set(KISSFFT_TEST OFF CACHE BOOL "Disable kissfft tests" FORCE)
set(REPROC++ ON CACHE BOOL "Build reproc++" FORCE)


# Include vendored dependencies that have CMake projects
add_subdirectory("${VENDOR_DIR}/PlatformFolders-4.2.0")
add_subdirectory("${VENDOR_DIR}/reproc-14.2.5")
add_subdirectory("${VENDOR_DIR}/kissfft-131.1.0")

# (Optional) Create interface targets for header-only libs if desired
add_library(ghc_filesystem INTERFACE)
target_include_directories(ghc_filesystem INTERFACE "${VENDOR_DIR}/ghc_filesystem/include")

add_library(kissnet INTERFACE)
target_include_directories(kissnet INTERFACE "${VENDOR_DIR}/kissnet-master-34b751b")

# List your source files (note the fixed path for TLSF)
set(API_SRC
    ${API_ROOT}/src/sonicpi_api.cpp
    ${API_ROOT}/src/string_utils.cpp
    ${API_ROOT}/src/file_utils.cpp

    ${API_ROOT}/include/api/string_utils.h
    ${API_ROOT}/include/api/file_utils.h
    ${API_ROOT}/include/api/logger.h

    ${VENDOR_DIR}/TLSF-2.4.6/src/tlsf.c
)

set(OSC_SRC
    ${API_ROOT}/src/osc/osc_handler.cpp
    ${API_ROOT}/src/osc/osc_sender.cpp
    ${API_ROOT}/src/osc/osc_server.cpp
    ${API_ROOT}/src/osc/tcp_osc_server.cpp
    ${API_ROOT}/src/osc/udp_osc_server.cpp

    ${API_ROOT}/include/api/osc/osc_handler.h
    ${API_ROOT}/include/api/osc/osc_sender.h
    ${API_ROOT}/include/api/osc/osc_server.h
    ${API_ROOT}/include/api/osc/tcp_osc_server.h
    ${API_ROOT}/include/api/osc/udp_osc_server.h
    ${API_ROOT}/include/api/osc/osc_pkt.hh
    ${API_ROOT}/include/api/osc/udp.hh
)

set(BUFFER_SRC
    ${API_ROOT}/src/audio/audio_processor.cpp
    ${API_ROOT}/include/api/audio/audio_processor.h
    ${API_ROOT}/include/api/audio/scope_buffer.hpp
    ${API_ROOT}/include/api/audio/server_shm.hpp
)

# Create the static library target
add_library(${PROJECT_NAME} STATIC ${API_SRC} ${OSC_SRC} ${BUFFER_SRC})
add_library(SonicPi::API ALIAS ${PROJECT_NAME})

# Include directories
target_include_directories(${PROJECT_NAME}
    PUBLIC
        ${API_ROOT}/include
        ${VENDOR_DIR}/ghc_filesystem/include
        ${VENDOR_DIR}/kissnet-master-34b751b
        ${VENDOR_DIR}/reproc-14.2.5/reproc++/include
        ${VENDOR_DIR}/PlatformFolders-4.2.0
        ${VENDOR_DIR}/kissnet-master-34b751b/
        ${VENDOR_DIR}/kissfft-131.1.0/

    PRIVATE
        ${VENDOR_DIR}/scsynth-boost-1.74.0
        ${VENDOR_DIR}/TLSF-2.4.6/src
)

# Link to the vendored targets
target_link_libraries(${PROJECT_NAME}
    PUBLIC
        sago::platform_folders
        reproc
        reproc++
        kissfft
)

# Platform-specific link libraries
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    target_link_libraries(${PROJECT_NAME}
        PUBLIC
            stdc++fs
            rt
    )
endif()

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    # Windows-specific libraries, if any
endif()

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
    # macOS-specific libraries, if any
endif()

target_compile_definitions(${PROJECT_NAME} PUBLIC
    _CRT_SECURE_NO_WARNINGS
    _WINSOCK_DEPRECATED_NO_WARNINGS
    BOOST_DATE_TIME_NO_LIB
    WIN32_LEAN_AND_MEAN
)

# Organize source groups (optional)
source_group("Api" FILES ${API_SRC})
source_group("Api\\Osc" FILES ${OSC_SRC})
source_group("Api\\Audio" FILES ${BUFFER_SRC})
