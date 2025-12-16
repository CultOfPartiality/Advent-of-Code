const { assert } = require('console');
const fs = require('fs');

function solution(filepath) {
    data = fs.readFileSync(filepath, 'UTF8').toString()
    .replaceAll(/\r\n/g,"\n").split('\n').map(x => x.split(",").map(y => Number(y)))

    maxSize = 0
    for (let i = 0; i < data.length; i++) {
        for (let j = i+1; j < data.length; j++) {
            maxSize = Math.max(maxSize,(Math.abs(data[i][0]-data[j][0])+1) * (Math.abs(data[i][1]-data[j][1])+1))
        }
    }
    return maxSize
}

assert(solution(__dirname + '/../testcases/test1.txt') == 50)
assert(solution(__dirname + '/../input.txt') == 4790063600)
console.log("Part 1:", solution(__dirname + '/../input.txt'))