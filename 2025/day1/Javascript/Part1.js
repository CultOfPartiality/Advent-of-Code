const { assert } = require('console');
const fs = require('fs');

function part1(filepath) {
    zeros = 0
    dial = 50
    fs.readFileSync(filepath, 'UTF8').toString().split('\n').forEach(element => {
        op =  new Object({
            dir: element.charAt(0),
            num: element.substring(1)
        })

        while(op.num > 0){
            dial = (100 + (op.dir == "L" ? dial-1 : dial+1)) % 100
            op.num--
        }
        if(dial == 0)
            zeros++
    });
    return zeros
}

assert(part1(__dirname+'/../testcases/test1.txt')==3)
assert(part1(__dirname+'/../input.txt')==1036)
console.log("Part 1:",part1(__dirname+'/../input.txt'))

