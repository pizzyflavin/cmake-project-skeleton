#!/bin/bash

# Read argument 2
IFS=',' read -ra DIRS <<< "$2"

# Argument 3 is a list of file names/types to include in clang-tidy analysis
FILE_TYPES=
IFS=',' read -ra  ENTRIES <<< "3"
for entry in "${ENTRIES[@]}"; do
    FILE_TYPES="$FILE_TYPES -o -iname $entry"
done

# Remove the initial `-o` for the first file type
# otherwise the rules will not be properly parsed
FILE_TYPES=${FILE_TYPES:3:${#FILE_TYPES}}

# Argument 1 is the path to the directory containing the compile_commands.json file
BUILD_OUTPUT_FOLDER=${1:-buildresults}

find ${DIRS[@]} ${FILE_TYPES} \
        | xargs clang-tidy -p $BUILD_OUTPUT_FOLDER

