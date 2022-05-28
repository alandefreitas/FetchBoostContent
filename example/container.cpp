//
// Copyright (c) 2022 alandefreitas (alandefreitas@gmail.com)
//
// Distributed under the Boost Software License, Version 1.0.
// https://www.boost.org/LICENSE_1_0.txt
//

#include <boost/container/small_vector.hpp>
#include <iostream>

int main()
{
    boost::container::small_vector<int, 5> v(3, 6);
    std::cout << v[0] * v[1] * v[2] << "\n";
    return 0;
}
