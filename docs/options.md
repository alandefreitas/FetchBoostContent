# Options

The following CMake variables can be set before calling `FetchBoostContent_Populate` to influence its behaviour:

| Option                             | Default | Description                                                            | 
|------------------------------------|---------|------------------------------------------------------------------------|
| `FETCH_BOOST_CONTENT_VERBOSE`      | `0`     | Verbose output level                                                   | 
| `FETCH_BOOST_CONTENT_QUIET`        | `OFF`   | quiet output                                                           | 
| `FETCH_BOOST_CONTENT_EXCLUDE`      | `""`    | exclude a default subdirectory ("include", "src", or "test") from scan | 
| `FETCH_BOOST_CONTENT_IGNORE`       | `""`    | exclude top-level dependency even wen found in scan                    | 
| `FETCH_BOOST_CONTENT_INCLUDE`      | `""`    | additional subdirectory to scan                                        | 
| `FETCH_BOOST_CONTENT_IGNORE_CACHE` | `OFF`   | ignore cached dependency list (rescan files every time)                | 

--8<-- "docs/references.md"
