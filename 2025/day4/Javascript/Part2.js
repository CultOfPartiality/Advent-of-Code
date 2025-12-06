const { assert } = require('console');
const fs = require('fs');

function part2(filepath) {
    rows = fs.readFileSync(filepath, 'UTF8').toString()
    .replaceAll(/\r\n/g,"\n").split('\n')
    .map(x =>  x.split(''))
    
    rows.forEach(x => {x.unshift(".");x.push(".");})
    rows.unshift(Array(rows[0].length).fill("."))
    rows.push(Array(rows[0].length).fill("."))

    totalRemoved = 0
	do{
		rollRemoved = false
		for (let y = 1; y < (rows.length-1); y++) {
			for (let x = 1; x < (rows[0].length-1); x++) {
				if(rows[y][x] == "@" ){
					subarray = rows.slice(y-1,y+2).flatMap(subRow => subRow.slice(x-1,x+2))
					surrounding = subarray.reduce((acc,x) => acc + Number(x == '@'),0)-1
					if(surrounding < 4){
						totalRemoved++
						rollRemoved = true
						rows[y][x] = "."
					}
				}
			}   
		}
	}while(rollRemoved)
    return totalRemoved
}

assert(part2(__dirname + '/../testcases/test1.txt') == 43)
assert(part2(__dirname + '/../input.txt') == 8643)
console.log("Part 2:", part2(__dirname + '/../input.txt'))