# Quickstart

## Integration 💻 

!!! example ""

    === "Downloading"
    
        You can copy the script from our repository in [`cmake/FetchBoostContent.cmake`](https://github.com/alandefreitas/FetchBoostContent/blob/master/cmake/FetchBoostContent.cmake) or the [release page](https://github.com/alandefreitas/FetchBoostContent/releases), and include it in your project.

        ```cmake
        include(cmake/FetchBoostContent.cmake)
        ```

    === "Download with CMake"

        When FetchContent is not going to be the main strategy for integrating Boost, a second alternative is to use CMake itself to [download the script file](https://cmake.org/cmake/help/latest/command/file.html#download) and include it only when needed.

        ```cmake
        if (USE_FETCH_CONTENT)
            set(url https://github.com/alandefreitas/FetchBoostContent/blob/master/cmake/FetchBoostContent.cmake)
            set(destination ${CMAKE_CURRENT_BINARY_DIR}/cmake/FetchBoostContent.cmake})
            if (NOT EXISTS destination)
                file(DOWNLOAD ${url} ${destination})
            endif()
            include(${destination})
        endif()
        ```

        This strategy might also be useful to keep the script up-to-date.
        
## Hello world 👋

{{ code_snippet("CMakeLists.txt", "include") }}

<hr/>

{{ code_snippet("CMakeLists.txt", "declare_and_make_available") }}

<hr/>

{{ code_snippet("CMakeLists.txt", "declare") }}

<hr/>

{{ code_snippet("CMakeLists.txt", "populate") }}

<hr/>

{{ code_snippet("CMakeLists.txt", "interface") }}

<hr/>

{{ code_snippet("example/CMakeLists.txt", "link_header_only") }}

<hr/>

{{ code_snippet("example/CMakeLists.txt", "link_built") }}

--8<-- "docs/references.md"