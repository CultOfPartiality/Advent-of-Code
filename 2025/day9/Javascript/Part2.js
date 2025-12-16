const { assert } = require('console');
const fs = require('fs');

function solution(filepath) {
    corners = fs.readFileSync(filepath, 'UTF8').toString()
    .replaceAll(/\r\n/g,"\n").split('\n').map(x => x.split(",")).map(
        x => {return {x:Number(x[0]),y:Number(x[1])}}
    )
    lines = corners.map((element,index,array) => [element,corners[(index+1) % corners.length]]);

    function IsLineVertical(a){return a[0].x == a[1].x}
    function DoLinesCross(a,b){
        //Lines will always be hoz or vert, and they have to fully cross, not just touch
        if( IsLineVertical(a) == IsLineVertical(b) ){return false}
        vert = IsLineVertical(a) ? a : b
        hoz = IsLineVertical(a) ? b : a

        hozXs = hoz.map(x => x.x).sort()
        vertYs = vert.map(x => x.y).sort()

        return (
            (hozXs[0] < vert[0].x && vert[0].x < hozXs[1]) &&
            (vertYs[0] < hoz[0].y && hoz[0].y < vertYs[1])
        )
    }
    //TODO Also need to consider a line that extends over the top and past another line in the same direction....

    maxSize = 0
    for (let i = 0; i < corners.length; i++) {
        for (let j = i+1; j < corners.length; j++) {
            areaCorners = [corners[i],{x:corners[i].x,y:corners[j].y},corners[j],{x:corners[j].x,y:corners[i].y}]
            areaSides = areaCorners.map((element,index,array) => [element,array[(index+1) % array.length]])
            anyCrosses = lines.map(
                line => areaSides.some(
                    side => DoLinesCross(side,line)
                )
            ).some(x => x);
            if(anyCrosses){
                console.log("Detected a cross")
                continue
            }
            size = (Math.abs(corners[i].x-corners[j].x)+1) * (Math.abs(corners[i].y-corners[j].y)+1)
            maxSize = Math.max(size,maxSize)
        }
    }
    console.log(maxSize)
    return maxSize

}

assert(solution(__dirname + '/../testcases/test1.txt') == 24)
assert(solution(__dirname + '/../input.txt') == 1516172795)
console.log("Part 2:", solution(__dirname + '/../input.txt'))