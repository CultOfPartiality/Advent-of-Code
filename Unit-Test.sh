

# Function, it's input, and the expected output
unit-test(){
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    NC='\033[0m'
    result=$($1 $2)

    echo -e -n "${YELLOW}Example $2: "
    if [[ $result -eq $3 ]]; then
        echo -e "${GREEN}Example passed ✔️${NC}"
    else
        echo -e -n "${RED}Example failed x | "
        echo -e "Expected '$3', produced '$result' ${NC}"
        exit
    fi
}

run-input(){
    PURPLE='\033[0;35m'
    NC='\033[0m'
    result=$($1 $2)
    echo -e "${PURPLE}Result: $result"
}