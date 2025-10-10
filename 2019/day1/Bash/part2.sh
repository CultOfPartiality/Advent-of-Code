#!/bin/bash

# Get the current script location, so we can reference things in a relative way
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# Unit tests framework
source "$SCRIPT_DIR/../../../Unit-Test.sh"

InputFile="$SCRIPT_DIR/../testcases/test1.txt"


CalcFuel() {
    x=$(( ($1/3) - 2))
    echo "$x"
}

#Arg1: Input file path
Solution()
{
    
    # Need to remove carriage returns, then read each line into an array
    readarray -t lines < <( tr -d "\r" < $1)
    outerTotal=0
    for index in "${!lines[@]}"; do
        fuel=$( CalcFuel "${lines[$index]}" )
        ((total=fuel))
        while [[ $fuel -gt 0 ]]; do
            fuel=$( CalcFuel $fuel )
            if [[ $fuel -gt 0 ]]; then
                ((total+=fuel))
            fi
        done
        ((outerTotal+=total))
    done
    echo "$outerTotal"
}

unit-test Solution "$SCRIPT_DIR/../testcases/test1.txt" 51316
unit-test Solution "$SCRIPT_DIR/../input.txt" 4934153
run-input Solution "$SCRIPT_DIR/../input.txt"