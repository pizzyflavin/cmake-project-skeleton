#!/bin/bash

# Find files to pass to clang-format, ignore src/gdtoa
find arch src test include -type d \( -path .src/gdtoa \) -prune -type f \
    -o -iname *.h -o -iname *.c -o -iname *.cpp -o -iname *.hpp \
    | xargs clang-format -style=file -i -fallback-style=none

