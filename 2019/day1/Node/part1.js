const { assert } = require('console');
const fs = require('fs');

function part1(filepath) {
    sum = 0;
    fs.readFileSync(filepath, 'UTF8')
        .toString().split('\n')
        .forEach((element,index,arr) => { sum += Math.floor(element/3)-2 });
    return sum
}

assert(part1(__dirname+'/../testcases/test1.txt')==34241)
assert(part1(__dirname+'/../input.txt')==3291356)
console.log("Part 1:",part1(__dirname+'/../input.txt'))

