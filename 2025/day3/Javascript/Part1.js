const { assert } = require('console');
const fs = require('fs');

function part1(filepath) {
    total = 0
    banks = fs.readFileSync(filepath, 'UTF8').toString().split('\n')
    
    banks.forEach(element => {
        
    });
    return total
}

assert(part1(__dirname + '/../testcases/test1.txt') == 357)
assert(part1(__dirname + '/../input.txt') == 17229)
console.log("Part 1:", part1(__dirname + '/../input.txt'))