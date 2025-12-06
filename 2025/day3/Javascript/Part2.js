const { assert } = require('console');
const fs = require('fs');

function part2(filepath) {
	banks = fs.readFileSync(filepath, 'UTF8').toString()
	.replaceAll(/\r\n/g,"\n").split('\n')
	.map(x =>  x.split('').map(y => Number(y)))
	
    total = 0
    banks.forEach(bank => {
		remaining = bank
		number = ''
		for (let i = 0; i < 12; i++) {
			digit = Math.max(...remaining.slice(0,(remaining.length-11+i)))
			number += digit
			remaining = remaining.slice(remaining.indexOf(digit)+1)
		}
		total+=Number(number)
    });
    return total
}

assert(part2(__dirname + '/../testcases/test1.txt') == 3121910778619)
assert(part2(__dirname + '/../input.txt') == 170520923035051)
console.log("Part 2:", part2(__dirname + '/../input.txt'))