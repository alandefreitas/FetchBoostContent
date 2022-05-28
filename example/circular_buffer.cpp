//
// Copyright (c) 2022 alandefreitas (alandefreitas@gmail.com)
//
// Distributed under the Boost Software License, Version 1.0.
// https://www.boost.org/LICENSE_1_0.txt
//

#include <boost/circular_buffer.hpp>
#include <iostream>

int main()
{
    // Create a circular buffer with a capacity for 3 integers.
    boost::circular_buffer<int> cb(3);

    // Insert three elements into the buffer.
    cb.push_back(1);
    cb.push_back(2);
    cb.push_back(3);

    for (auto x: cb)
        std::cout << x << ' ';
    std::cout << "\n";

    // The buffer is full now, so pushing subsequent
    // elements will overwrite the front-most elements.

    cb.push_back(4);  // Overwrite 1 with 4.
    cb.push_back(5);  // Overwrite 2 with 5.

    // The buffer now contains 3, 4 and 5.
    for (auto x: cb)
        std::cout << x << ' ';
    std::cout << "\n";

    // Elements can be popped from either the front or the back.
    cb.pop_back();  // 5 is removed.
    cb.pop_front(); // 3 is removed.

    // Leaving only one element with value = 4.
    for (auto x: cb)
        std::cout << x << ' ';
    std::cout << "\n";

    return 0;
}
