#
# Copyright (c) 2022 alandefreitas (alandefreitas@gmail.com)
#
# Distributed under the Boost Software License, Version 1.0.
# https://www.boost.org/LICENSE_1_0.txt
#

find_package(Threads)

#[link_header_only Linking interface target for all headers
add_executable(http-client-sync http-client-sync.cpp)
target_link_libraries(http-client-sync Boost::headers)
#]
target_link_libraries(http-client-sync Threads::Threads)
if (MSVC)
    target_compile_options(http-client-sync PRIVATE "/EHsc")
endif (MSVC)
target_compile_features(http-client-sync PRIVATE cxx_std_11)

#[link_convenience_target Linking convenience target for Boost proposal libs
add_executable(parse_url parse_url.cpp)
target_link_libraries(parse_url PRIVATE url_headers)
#]
if (MSVC)
    target_compile_options(parse_url PRIVATE "/EHsc")
endif (MSVC)
target_compile_features(parse_url PRIVATE cxx_std_11)

#[link_interface_conditional Linking interface target
if (NOT Boost_FOUND)
    #[link_interface Linking interface target
    add_executable(circular_buffer circular_buffer.cpp)
    target_link_libraries(circular_buffer Boost::circular_buffer)
    #]link_interface
else ()
    add_executable(circular_buffer circular_buffer.cpp)
    target_link_libraries(circular_buffer Boost::headers)
endif ()
#]link_interface_conditional
if (MSVC)
    target_compile_options(circular_buffer PRIVATE "/EHsc")
endif (MSVC)
target_compile_features(circular_buffer PRIVATE cxx_std_11)

#[link_built Linking a compiled target
add_executable(container container.cpp)
target_link_libraries(container Boost::container)
#]
if (MSVC)
    target_compile_options(container PRIVATE "/EHsc")
endif (MSVC)
target_compile_features(container PRIVATE cxx_std_11)

# Define WIN32_WINNT appropriately
if (WIN32 AND CMAKE_SYSTEM_VERSION)
    # Get windows version major and minor
    set(WIN_VERSION ${CMAKE_SYSTEM_VERSION})
    string(REGEX MATCH "^([0-9]+).([0-9])" WIN_VERSION ${WIN_VERSION})
    # Convert to HEX
    string(REGEX MATCH "^([0-9]+)" WIN_VERSION_MAJOR ${WIN_VERSION})
    if ("${WIN_VERSION_MAJOR}" MATCHES "10")
        set(WIN_VERSION_MAJOR "A")
        string(REGEX REPLACE "^([0-9]+)" ${WIN_VERSION_MAJOR} WIN_VERSION ${WIN_VERSION})
    elseif ("${WIN_VERSION_MAJOR}" MATCHES "11")
        set(WIN_VERSION_MAJOR "B")
        string(REGEX REPLACE "^([0-9]+)" ${WIN_VERSION_MAJOR} WIN_VERSION ${WIN_VERSION})
    endif ()
    # Prepend single digits with 0
    string(REGEX REPLACE "^([0-9A-Z])\\." "0\\1." WIN_VERSION ${WIN_VERSION})
    string(REGEX REPLACE "([^0-9A-Z])([0-9A-Z])" "\\10\\2" WIN_VERSION ${WIN_VERSION})
    # Erase "."
    string(REPLACE "." "" WIN_VERSION ${WIN_VERSION})
    set(WIN32_WINNT_VALUE "0x${WIN_VERSION}")
    target_compile_definitions(http-client-sync PUBLIC -D_WIN32_WINNT=${WIN32_WINNT_VALUE})
endif ()
