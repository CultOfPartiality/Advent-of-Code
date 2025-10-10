#!/bin/bash

# Get the current script location, so we can reference things in a relative way
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Unit tests framework
source "$SCRIPT_DIR/../../../Unit-Test.sh"

InputFile="$SCRIPT_DIR/../testcases/test1.txt"

#Arg1: Input file path
Solution(){
    # Need to remove carriage returns, then read each line into an array
    readarray -t lines < <( tr -d "\r" < $1)
    total=0
    for index in ${!lines[@]}; do
        ((total+= (lines[$index]/3) - 2 ))
    done
    echo $total
}

unit-test Solution "$SCRIPT_DIR/../testcases/test1.txt" 34241
unit-test Solution "$SCRIPT_DIR/../input.txt" 3291356
run-input Solution "$SCRIPT_DIR/../input.txt"