const { assert } = require('console');
const fs = require('fs');

function solution(filepath,joinCount) {
    data = fs.readFileSync(filepath, 'UTF8').toString()
    .replaceAll(/\r\n/g,"\n").split('\n').map(x => x.split(","))

    pairs = Array()
    for (let i = 0; i < data.length; i++) {
        for (let j = i+1; j < data.length; j++) {
            pair = new Object()
            pair.dist = Math.sqrt(
                (data[i][0]-data[j][0])**2 + 
                (data[i][1]-data[j][1])**2 + 
                (data[i][2]-data[j][2])**2
            )
            pair.junctions = [data[i],data[j]]
            pairs.push(pair)
        }
    }
    pairs.sort((a,b)=> a.dist-b.dist)
    subCircuits = []
    for (let i = 0; i < joinCount; i++) {
        newCircuit = new Set()
        newCircuit.add(pairs[i].junctions[0])
        newCircuit.add(pairs[i].junctions[1])
        subCircuits.forEach(set => {
            if(!set.isDisjointFrom(newCircuit)){
                newCircuit = newCircuit.union(set)
                subCircuits = subCircuits.filter(x => x !== set)
            }
        });
        subCircuits.push(newCircuit)
    }
    return subCircuits.sort((a,b)=>b.size-a.size).slice(0,3).reduce((acc,x) => acc*x.size, 1)
}

assert(solution(__dirname + '/../testcases/test1.txt',10) == 40)
assert(solution(__dirname + '/../input.txt',1000) == 121770)
console.log("Part 1:", solution(__dirname + '/../input.txt',1000))