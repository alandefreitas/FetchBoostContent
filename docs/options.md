# Options

The following CMake variables can be set before calling `FetchBoostContent_Populate` to influence its behaviour:

| Option                                   | Default | Description                                                   | 
|------------------------------------------|---------|---------------------------------------------------------------|
| Logging                                  |         |                                                               | 
| `FETCH_BOOST_CONTENT_VERBOSE`            | `0`     | Verbose output level                                          | 
| `FETCH_BOOST_CONTENT_QUIET`              | `OFF`   | quiet output                                                  | 
| Directories                              |         |                                                               | 
| `FETCH_BOOST_CONTENT_INCLUDE`            | `""`    | additional subdirectoroes to scan                             | 
| `FETCH_BOOST_CONTENT_EXCLUDE`            | `""`    | exclude a default subdirectory ("include", "src") from scan   | 
| Behavior                                 |         |                                                               | 
| `FETCH_BOOST_CONTENT_PRUNE_DEPENDENCIES` | `OFF`   | prune transitive dependencies on which library doesn't depend | 
| `FETCH_BOOST_CONTENT_IGNORE_CACHE`       | `OFF`   | ignore cached dependency list (rescan files every time)       | 
| `FETCH_BOOST_CONTENT_IGNORE`             | `""`    | exclude top-level dependency even when found in scan          | 

The `FETCH_BOOST_CONTENT_PRUNE_DEPENDENCIES` option will prune any transitive header-only dependencies on which the
main library does not rely. For instance, considering these header-only libraries:


```
A:
boost/a/a1.hpp
    includes boost/b/b1.hpp
    includes boost/b/b2.hpp

B:
boost/b/b1.hpp
    includes boost/c/c1.hpp
    includes boost/c/c2.hpp
boost/b/b2.hpp

C:
boost/c/c1.hpp
boost/c/c2.hpp
boost/c/c3.hpp
    includes boost/d/d1.hpp
    
D:
boost/d/d1.hpp
```

When `FETCH_BOOST_CONTENT_PRUNE_DEPENDENCIES` is OFF, this would fetch the libraries A, B, C, and D, because of the
transitive relationship A -> B -> C -> D. When `FETCH_BOOST_CONTENT_PRUNE_DEPENDENCIES` is ON, this would only fetch 
the libraries A, B, and C, because fetching the dependency D for the transitive relationship C -> D is only required
when A is indirectly using `boost/c/c3.hpp`.

Pruning makes the process of fetching faster. This is particularly useful when a given library happens to be at a 
high dependency level only for requiring a smaller feature from a library with many other transitive dependencies.
However, the scripts in C might depend on targets created by D. In this case, we cannot include C with
`add_subdirectory`. This is usually not a problem, as long as the libraries are header-only, as we can just use
`Boost::headers`. For compiled libraries, it's often easier to use `add_subdirectory`. 

--8<-- "docs/references.md"
