const { assert } = require('console');
const fs = require('fs');

function part1(filepath) {
    banks = fs.readFileSync(filepath, 'UTF8').toString()
    .replaceAll(/\r\n/g,"\n").split('\n')
    .map(x =>  x.split('').map(y => Number(y)))
    
    total = 0
    banks.forEach(bank => {
        first = Math.max(...bank.slice(0,-2))
        remaining = bank.slice(bank.indexOf(first)+1)
        second = Math.max(...remaining)
        total += first*10 + second
    });
    return total
}

assert(part1(__dirname + '/../testcases/test1.txt') == 357)
assert(part1(__dirname + '/../input.txt') == 17229)
console.log("Part 1:", part1(__dirname + '/../input.txt'))