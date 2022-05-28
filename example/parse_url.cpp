//
// Copyright (c) 2022 alandefreitas (alandefreitas@gmail.com)
//
// Distributed under the Boost Software License, Version 1.0.
// https://www.boost.org/LICENSE_1_0.txt
//

#define BOOST_URL_NO_LIB
#include <boost/url.hpp>
#include <boost/url/src.hpp>
#include <cstdlib>
#include <iostream>
#include <string>

int main()
{
    using namespace boost::urls;
    string_view s = "mailto:name@email.com";
    url_view u = parse_uri( s ).value();
    std::cout << u.scheme() << "\n";
    return EXIT_SUCCESS;
}
