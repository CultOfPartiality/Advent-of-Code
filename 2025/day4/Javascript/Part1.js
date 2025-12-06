const { assert } = require('console');
const fs = require('fs');

function part1(filepath) {
    rows = fs.readFileSync(filepath, 'UTF8').toString()
    .replaceAll(/\r\n/g,"\n").split('\n')
    .map(x =>  x.split(''))
    
    rows.forEach(x => {x.unshift(".");x.push(".");})
    rows.unshift(Array(rows[0].length).fill("."))
    rows.push(Array(rows[0].length).fill("."))

    total = 0
    for (let y = 1; y < (rows.length-1); y++) {
        for (let x = 1; x < (rows[0].length-1); x++) {
            if(rows[y][x] == "@" ){
                subarray = rows.slice(y-1,y+2).flatMap(subRow => subRow.slice(x-1,x+2))
                surrounding = subarray.reduce((acc,x) => acc + Number(x == '@'),0)-1
                if(surrounding < 4)
                    total++
            }
        }   
    }
    return total
}

assert(part1(__dirname + '/../testcases/test1.txt') == 13)
assert(part1(__dirname + '/../input.txt') == 1393)
console.log("Part 1:", part1(__dirname + '/../input.txt'))