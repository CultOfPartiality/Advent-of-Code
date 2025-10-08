#!/bin/bash

# Get the current script location, so we can reference things in a relative way
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


InputFile="$SCRIPT_DIR/../testcases/test1.txt"

#Arg1: Input file path
function Solution()
{
    # Need to remove carriage returns, then read each line into an array
    readarray -t lines < <( tr -d "\r" < $1)
    total=0
    for index in "${!lines[@]}"; do
        ((total+= (lines[$index]/3) - 2 ))
    done
    echo "$total"
}
GREEN='\033[0;32m'
echo -e "${GREEN}Result: $(Solution $InputFile)"