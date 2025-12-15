const { assert } = require('console');
const fs = require('fs');

function solution(filepath) {
    data = fs.readFileSync(filepath, 'UTF8').toString()
    .replaceAll(/\r\n/g,"\n").split('\n').map(x => x.split(""))

    beamsAbove = Array(data[0].length)
    beamsAbove[data[0].indexOf("S")] = 1
    for (let row = 1; row < data.length; row++) {
        nextBeams = Array(data[0].length).fill(0)
        beamsAbove.forEach((beamCount,index,array) => {
            if(data[row][index] == ".")
                nextBeams[index] += beamCount
            else if(data[row][index] == "^"){
                nextBeams[index-1] += beamCount
                nextBeams[index+1] += beamCount
            }
        });
        beamsAbove = structuredClone(nextBeams)
    }
    return beamsAbove.reduce((acc,x) => acc+x,0)
}

assert(solution(__dirname + '/../testcases/test1.txt') == 40)
assert(solution(__dirname + '/../input.txt') == 24292631346665)
console.log("Part 1:", solution(__dirname + '/../input.txt'))