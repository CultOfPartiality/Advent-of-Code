const { assert } = require('console');
const fs = require('fs');

function solution(filepath) {
    data = fs.readFileSync(filepath, 'UTF8').toString()
    .replaceAll(/\r\n/g,"\n").split('\n')

    ranges = data.filter(x => x.includes("-")).map(x => x.split("-").map(y => Number(y)))
    ids = data.filter(x => !x.includes("-")).map(x => Number(x))
    
    return ids.map(id => {
        return ranges.map(range => range[0] <= id && id <= range[1]).includes(true)
    }).reduce((acc,x) => acc+Number(x), 0)
    
}

assert(solution(__dirname + '/../testcases/test1.txt') == 3)
assert(solution(__dirname + '/../input.txt') == 613)
console.log("Part 1:", solution(__dirname + '/../input.txt'))