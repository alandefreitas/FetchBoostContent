# `FetchBoostContent_Declare`

## Boost library proposals

`FetchBoostContent_Declare` is particularly useful to experiment with Boost library proposals.

{{ code_snippet("CMakeLists.txt", "declare_proposal") }}
{{ code_snippet("CMakeLists.txt", "declare_proposal2") }}

Boost proposals are often very hard to integrate. Their CMake build scripts assume:

- the module is part of the build distribution and 
- usually contain no scripts for installing the library. 

This means the library will work with neither with [find_package] nor with [FetchContent]. The only alternatives are:

- to install a patched version of Boost on the system or
- to rewrite the build script for these libraries locally.

It's easy to see how this could be inconvenient.

`FetchBoostContent` makes integration much easier because the modules will be considered a regular Boost sub-library whose dependencies will also be fetched.

--8<-- "docs/references.md"
