const { assert } = require('console');
const fs = require('fs');

function solution(filepath) {
	data = fs.readFileSync(filepath, 'UTF8').toString()
		.replaceAll(/\r\n/g, "\n").split('\n').map(x => x.split("").reverse())

	total = 0
	numbers = []
	for (let col = 0; col < data[0].length; col++) {

		number = ''
		for (let row = 0; row < data.length - 1; row++) {
			number += data[row][col]
		}
		numbers.push(Number(number))

		op = data[data.length - 1][col]
		if(["*","+"].includes(op)) {
			if (op == "+")
				total += numbers.reduce((acc, x) => acc + x, 0)
			else
				total += numbers.reduce((acc, x) => acc * x, 1)
			numbers = []
			col++
		}
	}
	return total
}

assert(solution(__dirname + '/../testcases/test1.txt') == 3263827)
assert(solution(__dirname + '/../input.txt') == 9770311947567)
console.log("Part 2:", solution(__dirname + '/../input.txt'))