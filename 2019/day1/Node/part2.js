const { assert } = require('console');
const fs = require('fs');

function part2(filepath) {

    data = fs.readFileSync(filepath, 'UTF8').toString().split('\n');
    sum = 0;
    while (data.length > 0) {
        data = data.map((mass) => Math.floor(mass/3)-2 )
                .filter((fuel) => fuel > 0 );
        data.forEach((validFuel) => {sum+=validFuel});
    }
    return sum
}

assert(part2(__dirname+'/../testcases/test1.txt')==51316)
assert(part2(__dirname+'/../input.txt')==4934153)
console.log("Part 2:",part2(__dirname+'/../input.txt'))

