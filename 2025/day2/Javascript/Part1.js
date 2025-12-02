const { assert } = require('console');
const fs = require('fs');

function part1(filepath) {
    InvalidTotal = 0
    fs.readFileSync(filepath, 'UTF8').toString().split(',').forEach(element => {
        [start, end] = element.split("-").map(str => parseInt(str))

        for (let val = start; val <= end; val++) {
            if (val.toString().match(/^([1-9]\d*)\1$/)) {
                InvalidTotal += val
            }
        }
    });
    return InvalidTotal
}

assert(part1(__dirname + '/../testcases/test1.txt') == 1227775554)
assert(part1(__dirname + '/../input.txt') == 38310256125)
console.log("Part 1:", part1(__dirname + '/../input.txt'))