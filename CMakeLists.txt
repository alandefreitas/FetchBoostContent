#
# Copyright (c) 2022 alandefreitas (alandefreitas@gmail.com)
#
# Distributed under the Boost Software License, Version 1.0.
# https://www.boost.org/LICENSE_1_0.txt
#

#######################################################
### FetchBoostContent test application              ###
#######################################################
cmake_minimum_required(VERSION 3.5...3.16)

project(
        FetchBoostContentTest
        VERSION 0.0.1
        DESCRIPTION "FetchContent for Boost libraries"
        HOMEPAGE_URL "https://alandefreitas.github.io/FetchBoostContent/"
)

#[find_package_or_declare Find package or fetch
find_package(Boost COMPONENTS container)
if (NOT Boost_FOUND)
    #[include Including the script
    include(cmake/FetchBoostContent.cmake)
    #]

    # Example fetching Boost.Beast
    #[declare Declare content
    FetchBoostContent_Declare(
            boost_beast
            GIT_REPOSITORY https://github.com/boostorg/beast
            GIT_TAG        master
    )
    #]
    # fetch library...
    #]find_package_or_declare

    #[populate Declare content
    # Check if population has already been performed
    FetchBoostContent_GetProperties(boost_beast)
    if (NOT boost_beast_POPULATED)
        # Fetch the content using previously declared details
        FetchBoostContent_Populate(boost_beast)
        #]

        #[interface Source directory include directories
        # Create an interface target for all the include dirs
        add_library(boost_headers INTERFACE)
        add_library(Boost::headers ALIAS boost_headers)
        # <library>_SOURCE_DIRS contains the source dir for all <library> dependencies
        foreach (dir ${boost_beast_SOURCE_DIRS})
            target_include_directories(boost_headers INTERFACE ${dir}/include)
        endforeach()
        #]
    endif ()

    # Example fetching Boost.Container
    FetchBoostContent_Declare(
            boost_container
            # repository outside boostorg:
            GIT_REPOSITORY https://github.com/boostorg/container
            GIT_TAG        master
    )
    #[make_available_pattern The pattern of make available
    FetchBoostContent_GetProperties(boost_container)
    if (NOT boost_container_POPULATED)
        #[add_subdirs Adding subdirectories for all dependencies
        FetchBoostContent_Populate(boost_container)
        foreach (dir ${boost_container_SOURCE_DIRS})
            add_subdirectory(${dir})
        endforeach()
        #]
    endif ()
    #]make_available_pattern

    # Example fetching Boost.circular_buffer
    #[declare_and_make_available Declare and make available as target
    FetchBoostContent_Declare(
            boost_circular_buffer
            GIT_REPOSITORY https://github.com/boostorg/circular_buffer
            GIT_TAG        master
    )
    FetchBoostContent_MakeAvailable(boost_circular_buffer)
    #]
endif()

# Example fetching Boost.URL
# This is a Boost proposal that requires fetching even if Boost_FOUND
include(cmake/FetchBoostContent.cmake)

#[declare_proposal Declare Boost.URL proposal repo
FetchBoostContent_Declare(
        boost_url
        # repository outside boostorg:
        GIT_REPOSITORY https://github.com/CPPAlliance/url
        GIT_TAG        master
)
#]

#[declare_proposal2 Declare Boost.MySQL proposal repo
FetchBoostContent_Declare(
        boost_mysql
        # repository outside boostorg:
        GIT_REPOSITORY https://github.com/anarthal/mysql
        GIT_TAG        master
)
#]

# Check if library is already populated has already been performed
FetchBoostContent_GetProperties(boost_url)
if (NOT boost_url_POPULATED)
    #[proposal_populate
    # Fetch the content and maybe the dependencies
    FetchBoostContent_Populate(boost_url)
    #]
    if (Boost_FOUND)
        #[proposal_when_found
        # Create an interface target for boost + url headers
        add_library(url_headers INTERFACE)
        target_link_libraries(url_headers INTERFACE Boost::headers)
        target_include_directories(url_headers INTERFACE ${boost_url_SOURCE_DIR}/include)
        #]
    else()
        #[proposal_when_not_found
        # Add all dependencies to Boost::headers, including Boost.URL
        if (NOT TARGET boost_headers)
            add_library(boost_headers INTERFACE)
        endif()
        foreach (dir ${boost_url_SOURCE_DIRS})
            target_include_directories(boost_headers INTERFACE ${dir}/include)
        endforeach()
        #]
        #[proposal_convenience_interface
        # Create a url_headers target for boost + url to simplify linking
        add_library(url_headers INTERFACE)
        target_link_libraries(url_headers INTERFACE Boost::headers)
        #]
    endif()
endif ()

add_subdirectory(example)