const { assert } = require('console');
const fs = require('fs');

function part2(filepath) {
    InvalidTotal = 0
    fs.readFileSync(filepath, 'UTF8').toString().split(',').forEach(element => {
        [start, end] = element.split("-").map(str => parseInt(str))

        for (let val = start; val <= end; val++) {
            if (val.toString().match(/^([1-9]\d*)(\1)+$/)) {
                InvalidTotal += val
            }
        }
    });
    return InvalidTotal
}

assert(part2(__dirname + '/../testcases/test1.txt') == 4174379265)
assert(part2(__dirname + '/../input.txt') == 58961152806)
console.log("Part 1:", part2(__dirname + '/../input.txt'))