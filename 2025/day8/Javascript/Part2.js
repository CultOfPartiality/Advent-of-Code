const { assert } = require('console');
const fs = require('fs');

function solution(filepath) {
	data = fs.readFileSync(filepath, 'UTF8').toString()
		.replaceAll(/\r\n/g, "\n").split('\n').map(x => x.split(","))

	pairs = Array()
	for (let i = 0; i < data.length; i++) {
		for (let j = i + 1; j < data.length; j++) {
			pair = new Object()
			pair.dist = Math.sqrt(
				(data[i][0] - data[j][0]) ** 2 +
				(data[i][1] - data[j][1]) ** 2 +
				(data[i][2] - data[j][2]) ** 2
			)
			pair.junctions = [data[i], data[j]]
			pairs.push(pair)
		}
	}
	pairs.sort((a, b) => a.dist - b.dist)
	newCircuit = new Set()
	newCircuit.add(pairs[0].junctions[0])
	newCircuit.add(pairs[0].junctions[1])
	subCircuits = [newCircuit]
	i=1
	for (; subCircuits[0].size != data.length; i++) {
		newCircuit = new Set()
		newCircuit.add(pairs[i].junctions[0])
		newCircuit.add(pairs[i].junctions[1])
		subCircuits.forEach(set => {
			if (!set.isDisjointFrom(newCircuit)) {
				newCircuit = newCircuit.union(set)
				subCircuits = subCircuits.filter(x => x !== set)
			}
		});
		subCircuits.push(newCircuit)
	}
	return pairs[i-1].junctions[0][0] * pairs[i-1].junctions[1][0]
}

assert(solution(__dirname + '/../testcases/test1.txt') == 25272)
assert(solution(__dirname + '/../input.txt') == 7893123992)
console.log("Part 2:", solution(__dirname + '/../input.txt'))