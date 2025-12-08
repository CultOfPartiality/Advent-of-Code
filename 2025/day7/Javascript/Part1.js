const { assert } = require('console');
const fs = require('fs');

function solution(filepath) {
    data = fs.readFileSync(filepath, 'UTF8').toString()
    .replaceAll(/\r\n/g,"\n").split('\n').map(x => x.split(""))

    splits=0
    beamsAbove = [data[0].indexOf("S")]
    for (let row = 1; row < data.length; row++) {
        nextBeams = []
        beamsAbove.forEach(beam => {
            if(data[row][beam] == ".")
                nextBeams.push(beam)
            else if(data[row][beam] == "^"){
                nextBeams.push(beam-1)
                nextBeams.push(beam+1)
                splits++
            }
        });
        beamsAbove = nextBeams.filter((val, index, array) => array.indexOf(val) === index )
    }
    return splits
}

assert(solution(__dirname + '/../testcases/test1.txt') == 21)
assert(solution(__dirname + '/../input.txt') == 1562)
console.log("Part 1:", solution(__dirname + '/../input.txt'))