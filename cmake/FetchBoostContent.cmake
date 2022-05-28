#
# Copyright (c) 2022 alandefreitas (alandefreitas@gmail.com)
#
# Distributed under the Boost Software License, Version 1.0.
# https://www.boost.org/LICENSE_1_0.txt
#
if (NOT CMAKE_VERSION VERSION_LESS 3.10)
    include_guard()
endif ()

# Ensure FetchContent is available
if (CMAKE_VERSION VERSION_GREATER_EQUAL 3.11)
    include(FetchContent)
else ()
    file(DOWNLOAD
            "https://gitlab.kitware.com/cmake/cmake/raw/v3.11.3/Modules/FetchContent.cmake"
            "${CMAKE_BINARY_DIR}/Modules/FetchContent.cmake")
    file(DOWNLOAD
            "https://gitlab.kitware.com/cmake/cmake/raw/v3.11.3/Modules/FetchContent/CMakeLists.cmake.in"
            "${CMAKE_BINARY_DIR}/Modules/FetchContent/CMakeLists.cmake.in")
    include(${CMAKE_BINARY_DIR}/Modules/FetchContent.cmake)
endif ()

set(CURRENT_FETCH_BOOST_CONTENT_VERSION 0.0.1)

function(__FetchBoostContent_sanitize_name name output)
    string(TOLOWER ${name} name)
    string(REPLACE "/" "_" name ${name})
    string(FIND ${name} boost_ idx)
    if (NOT idx EQUAL 0)
        message(FATAL_ERROR "Module ${name} does not have the \"boost_\" prefix")
    endif ()
    set(${output} ${name} PARENT_SCOPE)
endfunction()

# A version of FetchContent_Declare for Boost Libraries
# This function will store the information about the library
# as a separate global property, so we can later identify
# that this is a Boost library and we need to scan its dependencies
function(FetchBoostContent_Declare name)
    __FetchBoostContent_sanitize_name(${name} name)

    # Check if already defined
    set(savedDetailsPropertyName "_FetchBoostContent_${name}_savedDetails")
    get_property(alreadyDefined GLOBAL PROPERTY ${savedDetailsPropertyName} DEFINED)
    if (alreadyDefined)
        return()
    endif ()

    # Remember the package arguments
    define_property(GLOBAL
            PROPERTY ${savedDetailsPropertyName}
            BRIEF_DOCS "Arguments for ${name}"
            FULL_DOCS "Arguments for ${name}")
    set_property(GLOBAL PROPERTY ${savedDetailsPropertyName} ${ARGN})

    # Make an internal call to FetchContent and store it there too
    FetchContent_declare(${name} ${ARGN})
endfunction()

# Get the library properties. This is usually used to identify
# if the library has already been populated. Variables for all
# other properties will still be set. These properties are
# only defined if a previous call to Populate has been made.
function(FetchBoostContent_GetProperties name)
    __FetchBoostContent_sanitize_name(${name} name)
    set(singleValueArgs SOURCE_DIR BINARY_DIR POPULATED)
    cmake_parse_arguments(ARG "" "${singleValueArgs}" "" ${ARGN})

    # Provide all properties if no specific properties requested
    if (NOT ARG_SOURCE_DIR AND NOT ARG_BINARY_DIR AND NOT ARG_POPULATED)
        set(ARG_SOURCE_DIR ${${name}_SOURCE_DIR})
        set(ARG_BINARY_DIR ${${name}_BINARY_DIR})
        set(ARG_POPULATED ${${name}_POPULATED})
    endif ()

    # Return properties
    set(PROPERTY_SUFFIXES
            # Output Property / Global Property Suffix
            SOURCE_DIR sourceDir
            BINARY_DIR binaryDir
            POPULATED populated)
    while (PROPERTY_SUFFIXES)
        list(POP_FRONT PROPERTY_SUFFIXES PROPERTY SUFFIX)
        if (ARG_${PROPERTY})
            set(propertyName "_FetchBoostContent_${name}_${SUFFIX}")
            get_property(value GLOBAL PROPERTY ${propertyName})
            if (value)
                set(${ARG_${PROPERTY}} ${value} PARENT_SCOPE)
            endif ()
        endif ()
    endwhile ()
endfunction()

# Populate the library properties from the declared data.
function(FetchBoostContent_Populate name)
    if (NOT name)
        message(FATAL_ERROR "Empty contentName not allowed for FetchBoostContent_Populate()")
    endif ()
    __FetchBoostContent_sanitize_name(${name} name)

    # Call underlying Populate function
    # This might have already been called indirectly by FetchBoostContent_Populate.
    # In this case, we just need to obtain the properties and mark it as Populated
    # directly by FetchBoostContent_Populate too.
    FetchContent_GetProperties(${name})
    if (NOT ${name}_POPULATED)
        FetchContent_Populate(${name} ${ARGN})
    endif()

    # Set properties and return values based on FetchContent_Populate
    set(PROPERTY_SUFFIXES
            SOURCE_DIR sourceDir
            BINARY_DIR binaryDir
            POPULATED populated)
    while (PROPERTY_SUFFIXES)
        list(POP_FRONT PROPERTY_SUFFIXES PROPERTY SUFFIX)
        # If FetchContent_Populate returned this property
        # Set the boost version of the property too
        if (${name}_${PROPERTY})
            set(propertyName "_FetchBoostContent_${name}_${SUFFIX}")
            define_property(GLOBAL
                    PROPERTY ${propertyName}
                    BRIEF_DOCS "POPULATED property for ${contentName}"
                    FULL_DOCS "POPULATED property for ${contentName}")
            set_property(GLOBAL PROPERTY ${propertyName} ${${name}_${PROPERTY}})
            # Return the value
            set(${name}_${PROPERTY} ${${name}_${PROPERTY}} PARENT_SCOPE)
        endif ()
    endwhile ()

    # At this point, FetchContent would be done.
    # If the Boost libraries have already been found at the parent scope,
    # then this is also done. This should only be the case for Boost library
    # proposals.
    if(Boost_FOUND)
        return()
    endif()

    # For Boost libraries in general, we still need to identify and populate dependencies.
    # The following replicates a logic similar to depinst.py for fetching dependencies.

    # Set default options
    set(PopulateOptions
            # Option / Variable / Default
            # "enable verbose output"
            FETCH_BOOST_CONTENT_VERBOSE verbose 0
            # "quiet output (opposite of -v)"
            FETCH_BOOST_CONTENT_QUIET quiet OFF
            # "exclude a default subdirectory (\"include\", \"src\", or \"test\") from scan; can be repeated"
            FETCH_BOOST_CONTENT_EXCLUDE exclude ""
            # "exclude top-level dependency even when found in scan; can be repeated"
            FETCH_BOOST_CONTENT_IGNORE ignore ""
            # "additional subdirectory to scan; can be repeated"
            FETCH_BOOST_CONTENT_INCLUDE include ""
            )
    while (PopulateOptions)
        list(POP_FRONT PopulateOptions Option Variable Default)
        if (${Option})
            set(${Variable} ${${Option}})
        else ()
            set(${Variable} ${Default})
        endif ()
    endwhile ()
    if (quiet)
        set(verbose -1)
    endif ()
    set(library ${name})

    # Print according to verbose level
    function(vprint level)
        if (quiet)
            return()
        endif ()
        if (verbose GREATER_EQUAL level)
            # Verbosity level will come from CMake, while
            # this allows a lower custom level
            if (level GREATER_EQUAL 2)
                message("${ARGN}")
            elseif (level EQUAL 1 OR verbose EQUAL 0)
                message(STATUS "${ARGN}")
            else (level EQUAL 0)
                message(STATUS "** ${ARGN} **")
            endif ()
        endif ()
    endfunction()
    set(FetchLevel 0)
    vprint(0 "Fetching (${FetchLevel}): ${library}")
    math(EXPR FetchLevel "${FetchLevel}+1")

    # Identify the branch for other dependency downloads
    set(savedDetailsPropertyName "_FetchBoostContent_${library}_savedDetails")
    get_property(alreadyDefined GLOBAL PROPERTY ${savedDetailsPropertyName} DEFINED)
    if (NOT alreadyDefined)
        message(FATAL_ERROR "_FetchBoostContent_${library}_savedDetails should be defined")
    endif ()
    get_property(DeclaredArgs GLOBAL PROPERTY ${savedDetailsPropertyName})
    set(oneValueArgs GIT_TAG HG_TAG CVS_TAG)
    cmake_parse_arguments(ARG "" "${oneValueArgs}" "" ${DeclaredArgs})
    set(libs_BRANCH master)
    foreach (tag ${ARG_GIT_TAG} ${ARG_HG_TAG} ${ARG_CVS_TAG})
        if (tag)
            set(libs_BRANCH ${tag})
        endif ()
    endforeach ()
    string(REGEX MATCH "^(boost-\\d+.\\d+.\\d+)$" m1 ${libs_BRANCH})
    string(REGEX MATCH "^(boost-\\d+.\\d+.\\d+).beta1$" m2 ${libs_BRANCH})
    if (NOT m1 AND NOT m2 AND NOT libs_BRANCH STREQUAL develop)
        set(libs_BRANCH master)
    endif ()

    # Read the exceptions file
    # exceptions.txt is the output of "boostdep --list-exceptions"
    # and it's part of the boostdep project. We download this file from
    # the appropriate branch and cache it.
    vprint(1 "Reading exceptions.txt")
    if (NOT EXISTS ${CMAKE_BINARY_DIR}/boost_exceptions.txt)
        file(DOWNLOAD
            "https://raw.githubusercontent.com/boostorg/boostdep/${libs_BRANCH}/depinst/exceptions.txt"
            "${CMAKE_BINARY_DIR}/boost_exceptions.txt")
    endif ()
    file(READ "${CMAKE_BINARY_DIR}/boost_exceptions.txt" f)
    string(REGEX REPLACE ";" "\\\\;" f "${f}")
    string(REGEX REPLACE "\n" ";" f "${f}")
    foreach (line ${f})
        string(STRIP ${line} line)
        string(REGEX MATCH "(.*):$" m ${line})
        if (CMAKE_MATCH_COUNT)
            string(REPLACE "~" "/" module ${CMAKE_MATCH_1})
        else ()
            set(header ${line})
            set(exception_${header} ${module})
            list(APPEND exception_headers ${header})
        endif ()
    endforeach ()

    # Aggregate all source dirs
    set(SOURCE_DIRS ${${library}_SOURCE_DIR})
    set(BINARY_DIRS ${${library}_BINARY_DIR})

    # Function to fetch modules
    function(fetch_modules)
        cmake_parse_arguments(ARG "" "" "MODULES" ${ARGN})
        set(modules ${ARG_MODULES})

        if (modules)
            vprint(0 "Fetching (${FetchLevel}): ${modules}")
            math(EXPR FetchLevel "${FetchLevel}+1")
            set(FetchLevel ${FetchLevel} PARENT_SCOPE)

            foreach (module ${modules})
                __FetchBoostContent_sanitize_name(${module} module)

                # Check properties
                set(savedDetailsPropertyName "_FetchBoostContent_${module}_savedDetails")
                get_property(alreadyDefined GLOBAL PROPERTY ${savedDetailsPropertyName} DEFINED)

                # Declare if not declared
                if (NOT alreadyDefined)
                    string(FIND ${module} boost_ idx)
                    if (idx EQUAL 0)
                        string(SUBSTRING ${module} 6 -1 repo)
                    else ()
                        set(repo ${module})
                    endif ()
                    FetchBoostContent_Declare(
                            ${module}
                            GIT_REPOSITORY https://github.com/boostorg/${repo}
                            GIT_TAG ${libs_branch}
                    )
                endif ()

                # Populate if not populated
                FetchContent_GetProperties(${module})
                if (NOT ${module}_POPULATED)
                    FetchContent_Populate(${module})
                endif ()

                # Remember source dir
                if (NOT ${${module}_SOURCE_DIR} IN_LIST SOURCE_DIRS)
                    list(APPEND SOURCE_DIRS ${${module}_SOURCE_DIR})
                    list(APPEND BINARY_DIRS ${${module}_BINARY_DIR})
                    set(SOURCE_DIRS ${SOURCE_DIRS} PARENT_SCOPE)
                    set(BINARY_DIRS ${BINARY_DIRS} PARENT_SCOPE)
                endif ()
            endforeach ()
        endif ()
    endfunction()

    # Function to scan module dependencies
    function(module_for_header header OUT_VARIABLE)
        if (header IN_LIST exception_headers)
            set(${OUT_VARIABLE} ${exception_${header}})
        else ()
            # Identify modules from include, but we cannot ensure ${m} is a module
            # because we don't have access to the super-project here
            set(EXPRESSIONS
                    # boost/function.hpp
                    "(boost/[^\\./]*)\\.h[a-z]*$"
                    # boost/numeric/conversion.hpp
                    "(boost/numeric/[^\\./]*)\\.h[a-z]*$"
                    # boost/numeric/conversion/header.hpp
                    "(boost/numeric/[^/]*)/"
                    # boost/function/header.hpp
                    "(boost/[^/]*)/"
                    )
            foreach (exp ${EXPRESSIONS})
                string(REGEX MATCH ${exp} m ${header})
                if (CMAKE_MATCH_COUNT)
                    string(REPLACE "/" "_" module ${CMAKE_MATCH_1})
                    set(${OUT_VARIABLE} ${module} PARENT_SCOPE)
                    return()
                endif ()
            endforeach ()
            set(${OUT_VARIABLE} PARENT_SCOPE)
            vprint(0 "Cannot determine module for header ${h}")
        endif ()
    endfunction()

    function(scan_directory module dir)
        # Parse arguments
        cmake_parse_arguments(ARG "" "" "DEPS" ${ARGN})
        vprint(1 "Scanning directory ${dir}")
        if (NOT ARG_DEPS)
            message(FATAL_ERROR "scan_directory: no DEPS argument")
        else ()
            set(deps ${ARG_DEPS})
        endif ()

        # Optimization:
        # Dependencies are moved to front of the list so they
        # represent what targets should be created first.
        # This is list of deps we have already moved before the
        # current ${module}
        set(moved_deps ${module})

        # Try to use the cache file first
        set(cache_file ${dir}/dependencies.txt)
        if (EXISTS ${cache_file})
            file(READ ${cache_file} module_deps)
            foreach (mod ${module_deps})
                if (NOT mod IN_LIST deps)
                    vprint(1 "Adding dependency ${mod}")
                    list(PREPEND deps ${mod} 0)
                elseif (NOT mod IN_LIST moved_deps)
                    # ensure dep comes before module to indicate dependency
                    list(FIND deps ${module} this_idx)
                    list(FIND deps ${mod} idx)
                    if (idx GREATER this_idx)
                        vprint(2 "Moving dependency ${mod}")
                        list(REMOVE_AT deps ${idx})
                        list(GET deps ${idx} v)
                        list(REMOVE_AT deps ${idx})
                        list(PREPEND deps ${mod} ${v})
                        list(APPEND moved_deps ${mod})
                    endif ()
                endif ()
            endforeach ()
            set(DIR_DEPS ${deps} PARENT_SCOPE)
            return()
        endif ()

        # Scan files for dependencies the first time
        file(GLOB_RECURSE files "${dir}/*")
        foreach (file ${files})
            set(fn ${file})
            file(RELATIVE_PATH rel_fn ${dir} ${fn})
            vprint(2 "Scanning file ${rel_fn}")
            # Scan header dependencies
            file(READ "${fn}" f)
            string(REGEX REPLACE ";" "\\\\;" f "${f}")
            string(REGEX REPLACE "\n" ";" f "${f}")
            foreach (line ${f})
                string(STRIP "${line}" line)
                string(REGEX MATCH "[ \\t]*#[ \\t]*include[ \\t]*[\"<](boost/[^\">]*)[\">]" _ "${line}")
                if (CMAKE_MATCH_COUNT)
                    set(h ${CMAKE_MATCH_1})
                    module_for_header(${h} mod)
                    if (mod)
                        if (NOT mod IN_LIST module_deps)
                            list(APPEND module_deps ${mod})
                        endif ()
                        if (NOT mod IN_LIST deps)
                            vprint(1 "Adding dependency ${mod}")
                            list(PREPEND deps ${mod} 0)
                        elseif (NOT mod IN_LIST moved_deps)
                            # ensure dep comes before module to indicate dependency
                            list(FIND deps ${module} this_idx)
                            list(FIND deps ${mod} idx)
                            if (idx GREATER this_idx)
                                vprint(1 "Moving dependency ${mod} (${file})")
                                list(REMOVE_AT deps ${idx})
                                list(GET deps ${idx} v)
                                list(REMOVE_AT deps ${idx})
                                list(PREPEND deps ${mod} ${v})
                                list(APPEND moved_deps ${mod})
                            endif ()
                        endif ()
                    endif ()
                endif ()
            endforeach ()
        endforeach ()

        # Cache dependencies for this module dir
        if (NOT EXISTS ${cache_file})
            file(WRITE ${dir}/dependencies.txt "${module_deps}")
        endif ()

        # Return new deps to parent scope
        set(DIR_DEPS ${deps} PARENT_SCOPE)
    endfunction()

    function(scan_module_dependencies module)
        vprint(1 "Scanning module ${module}")
        set(multiValueArgs DEPS DIRS)
        cmake_parse_arguments(ARG "" "" "${multiValueArgs}" ${ARGN})
        set(deps ${ARG_DEPS})
        set(dirs ${ARG_DIRS})

        # Ensure library is populated
        FetchContent_GetProperties(${module})
        if (NOT ${module}_POPULATED)
            FetchContent_Populate(${module})
            message(FATAL_ERROR "${module} has not been populated yet")
        endif ()
        if (NOT EXISTS ${${module}_SOURCE_DIR})
            message(FATAL_ERROR "${${module}_SOURCE_DIR} not found")
        endif ()

        # Scan directories
        foreach (dir ${dirs})
            if (EXISTS ${${module}_SOURCE_DIR}/${dir})
                scan_directory(${module} ${${module}_SOURCE_DIR}/${dir} DEPS ${ARG_DEPS})
                set(ARG_DEPS ${DIR_DEPS})
            endif ()
        endforeach ()

        # Return new deps
        set(MODULE_DEPS ${ARG_DEPS} PARENT_SCOPE)
    endfunction()

    function(fetch_module_dependencies)
        cmake_parse_arguments(ARG "" "" "DEPS" ${ARGN})
        set(deps ${ARG_DEPS})

        # Mark modules as installed in deps
        set(deps_copy ${deps})
        while (deps_copy)
            list(POP_FRONT deps_copy module installed)
            if (installed EQUAL 0)
                list(APPEND modules ${module})
                list(FIND deps ${module} idx)
                if (idx EQUAL -1)
                    message(FATAL_ERROR "Cannot find ${module} in dependencies")
                else ()
                    list(REMOVE_AT deps ${idx})
                    list(REMOVE_AT deps ${idx})
                    list(INSERT deps ${idx} ${module} 1)
                endif ()
            endif ()
        endwhile ()

        # Return here if there are no modules to fetch
        if (NOT modules)
            set(MODULES_LENGTH 0 PARENT_SCOPE)
            set(FETCH_DEPS ${deps} PARENT_SCOPE)
            return()
        endif ()

        # Fetch all modules and return dirs to the caller
        fetch_modules(MODULES ${modules})
        set(FetchLevel ${FetchLevel} PARENT_SCOPE)
        set(SOURCE_DIRS ${SOURCE_DIRS} PARENT_SCOPE)
        set(BINARY_DIRS ${BINARY_DIRS} PARENT_SCOPE)

        # Scan these module dependencies for the next round
        foreach (module ${modules})
            scan_module_dependencies(${module} DEPS ${deps} DIRS include src)
            set(deps ${MODULE_DEPS})
        endforeach ()

        # Return
        list(LENGTH modules modules_size)
        set(MODULES_LENGTH ${modules_size} PARENT_SCOPE)
        set(FETCH_DEPS ${deps} PARENT_SCOPE)
    endfunction()

    # Set initial list of modules and dirs
    set(module ${library})
    set(deps ${module} 1)
    set(dirs include src)
    foreach (dir ${exclude})
        list(REMOVE_ITEM dirs ${dir})
    endforeach ()
    foreach (dir ${include})
        list(APPEND dirs ${dir})
    endforeach ()

    # Scan dependencies of the main library to get dep level 1
    vprint(1 "Directories to scan: ${dirs}")
    scan_module_dependencies(${module} DEPS ${deps} DIRS ${dirs})

    # Remove any deps that should be ignored
    set(deps ${MODULE_DEPS})
    foreach (dep ${ignore})
        if (dep IN_LIST deps)
            vprint(1 "Ignoring dependency ${dep}")
            list(FIND deps ${dep} idx)
            if (NOT idx EQUAL -1)
                list(REMOVE_AT deps ${idx})
                list(REMOVE_AT deps ${idx})
            endif ()
        endif ()
    endforeach ()

    # Fetch dependencies for all other levels
    vprint(2 "Dependencies: ${deps}")
    fetch_module_dependencies(DEPS ${deps})
    set(deps ${FETCH_DEPS})
    while (MODULES_LENGTH)
        fetch_module_dependencies(DEPS ${deps})
        set(deps ${FETCH_DEPS})
    endwhile ()

    # Sort directories according to the level
    set(is_dep ON)
    foreach (module ${deps})
        if (is_dep)
            list(APPEND all_deps ${module})
            # Sort dependencies by level
            FetchContent_GetProperties(${module})
            if (${module}_POPULATED)
                if (${module}_SOURCE_DIR IN_LIST SOURCE_DIRS)
                    list(APPEND all_src_dirs ${${module}_SOURCE_DIR})
                    list(REMOVE_ITEM SOURCE_DIRS ${${module}_SOURCE_DIR})
                endif ()
                if (${module}_BINARY_DIR IN_LIST BINARY_DIRS)
                    list(APPEND all_bin_dirs ${${module}_BINARY_DIR})
                    list(REMOVE_ITEM BINARY_DIRS ${${module}_BINARY_DIR})
                endif ()
            endif ()
            set(is_dep OFF)
        else ()
            set(is_dep ON)
        endif ()
    endforeach ()
    list(PREPEND SOURCE_DIRS ${all_src_dirs})
    list(PREPEND BINARY_DIRS ${all_bin_dirs})

    # Return directories to the caller
    set(${library}_DEPS ${all_deps} PARENT_SCOPE)
    set(${library}_SOURCE_DIRS ${SOURCE_DIRS} PARENT_SCOPE)
    set(${library}_BINARY_DIRS ${BINARY_DIRS} PARENT_SCOPE)
endfunction()

# Attempt to use FetchContent_MakeAvailable for any
# boost library that works with add_subdirectory
# and its dependencies.
# Not many Boost libraries do work with add_subdirectory
# but the user can still try.
# In the future, we can attempt to adapt this function
# to get around boost limitations.
function(FetchBoostContent_MakeAvailable contentName)
    # Check if population has already been performed
    FetchBoostContent_GetProperties(${contentName})
    if (NOT ${contentName}_POPULATED)
        # Fetch the content using previously declared details
        FetchBoostContent_Populate(${contentName})

        # Bring the populated content into the build
        # In this case of Boost libraries, we are including
        # the directory and the dependency directories.
        # This means a second call to this function might try
        # this include a directory we have already included.
        # We have a few strategies to avoid this.
        # - In this variant, we avoid including the dependencies
        # for which there's a target already defined, because
        # we can't include the same subdirectory twice
        # - We also mark the directories we have included
        # here to ensure we don't include them twice/
        set(src_dirs ${${contentName}_SOURCE_DIRS})
        set(bin_dirs ${${contentName}_BINARY_DIRS})
        set(deps ${${contentName}_DEPS})
        while (src_dirs AND deps)
            list(POP_FRONT src_dirs src_dir)
            list(POP_FRONT bin_dirs bin_dir)
            list(POP_FRONT deps dep)
            if (NOT TARGET ${dep})
                set(dirIncludedPropertyName "_FetchBoostContent_MakeAvailable_${dep}_included")
                get_property(alreadyIncluded GLOBAL PROPERTY ${dirIncludedPropertyName} DEFINED)
                if (NOT alreadyIncluded)
                    set_property(GLOBAL PROPERTY ${dirIncludedPropertyName} 1)
                    if (EXISTS ${src_dir}/CMakeLists.txt)
                        add_subdirectory(${src_dir} ${bin_dir})
                    endif()
                    if (NOT TARGET boost_headers)
                        add_library(boost_headers INTERFACE)
                        add_library(Boost::headers ALIAS boost_headers)
                    endif()
                    get_target_property(boost_headers_imported boost_headers IMPORTED)
                    if (NOT boost_headers_imported)
                        target_include_directories(boost_headers INTERFACE ${src_dir}/include)
                    endif()
                endif()
            endif()
        endwhile()
    endif ()
endfunction()


