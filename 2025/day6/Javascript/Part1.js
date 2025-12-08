const { assert } = require('console');
const fs = require('fs');

function solution(filepath) {
    data = fs.readFileSync(filepath, 'UTF8').toString()
    .replaceAll(/\r\n/g,"\n").split('\n').map(x => x.trim().split(/\s+/))

    total = 0
    for (let col = 0; col < data[0].length; col++) {
        op = data[data.length-1][col]
        subtotal = Number(data[0][col])
        for (let row = 1; row < data.length-1; row++) {
            if(op == '*') subtotal *= Number(data[row][col])
            else subtotal += Number(data[row][col])
        }
        total += subtotal
    }
    return total
}

assert(solution(__dirname + '/../testcases/test1.txt') == 4277556)
assert(solution(__dirname + '/../input.txt') == 6891729672676)
console.log("Part 1:", solution(__dirname + '/../input.txt'))