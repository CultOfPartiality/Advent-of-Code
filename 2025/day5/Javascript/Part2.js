const { assert } = require('console');
const fs = require('fs');

function solution(filepath) {
	data = fs.readFileSync(filepath, 'UTF8').toString()
		.replaceAll(/\r\n/g, "\n").split('\n')

	ranges = data.filter(x => x.includes("-")).map(x => x.split("-").map(y => Number(y)))

	function CheckOverlap(a, b) {
		return (a[0] >= b[0] && a[0] <= b[1]) ||
			   (a[1] >= b[0] && a[1] <= b[1]) ||
			   (a[0] <= b[0] && a[1] >= b[1])
	}

	do {
		merges = 0
		for (let i1 = 0; i1 < ranges.length; i1++) {
			for (let i2 = i1 + 1; i2 < ranges.length; i2++) {
				[r1, r2] = [ranges[i1], ranges[i2]]
				if (CheckOverlap(r1, r2)) {
					ranges[i1] = [Math.min(r1[0], r2[0]), Math.max(r1[1], r2[1])]
					ranges.splice(i2, 1)
					merges++
				}
			}
		}
	} while (merges)
	return ranges.reduce((acc, range) => (acc + range[1] - range[0] + 1), 0)
}

assert(solution(__dirname + '/../testcases/test1.txt') == 14)
assert(solution(__dirname + '/../input.txt') == 336495597913098)
console.log("Part 2:", solution(__dirname + '/../input.txt'))