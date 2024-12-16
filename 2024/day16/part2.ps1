. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)


    $data = get-content $Path
    $height = $data.count
    $width = $data[0].length


    $start = $null
    $map = @{}
    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $coord = [coords]($y, $x)
            switch ($data[$y][$x]) {
                "S" { $start = $coord }
                "E" { $end = $coord }
            }
            $map[$coord.hash()] = [PSCustomObject]@{
                type        = ($data[$y][$x] -eq "#" ? "#" : ".")
                coord       = $coord
                lowestScore = [int32]::MaxValue
            }
        }
    }


    $deltas = @((-1, 0), (0, 1), (1, 0), (0, -1))
    $deer = [PSCustomObject]@{
        dir   = 1 #Right
        coord = $start
        score = 0
        path  = @($start)
    }

    $searchSpace = New-Object "System.Collections.Generic.PriorityQueue[psobject,int]"
    $searchSpace.Enqueue($deer, 0)

    $possibleDeers = @()
    $debug = 0
    while ($searchSpace.count) {
        $debug++
        $deer = $searchSpace.Dequeue()
        $delta = $deltas[$deer.dir]
        $infront = $deer.coord + $delta
        $infrontSpace = $map[$infront.Hash()]
        if ($deer.coord -eq $end) {
            $possibleDeers+=$deer
            continue
        }
        #possible moves: turn left/right, step forward.

        if ($infrontSpace.type -ne "#" -and $infrontSpace.lowestScore -ge ($deer.score + 1)) {
            $newDeer = $deer.psobject.Copy()
            $newDeer.score++
            $newDeer.coord += $delta
            $newDeer.path += $newDeer.coord
            $map[$infront.Hash()].lowestScore = $newDeer.score
            $searchSpace.Enqueue($newDeer, $newDeer.score)
        }

    
        $newDeer = $deer.psobject.Copy()
        $newDeer.dir = ($newDeer.dir + 1) % 4
        $newDeer.score += 1000
        $delta = $deltas[$newdeer.dir]
        $infront = $newdeer.coord + $delta
        $infrontSpace = $map[$infront.Hash()]
        if ($infrontSpace.type -ne "#" -and $infrontSpace.lowestScore -ge ($newdeer.score + 1)) {
            $map[$newDeer.coord.Hash()].lowestScore = $newDeer.score
            $newDeer.score++
            $newDeer.coord += $delta
            $newDeer.path += $newDeer.coord
            $map[$infront.Hash()].lowestScore = $newDeer.score
            $searchSpace.Enqueue($newDeer, $newDeer.score)
        }
        $newDeer = $deer.psobject.Copy()
        $newDeer.dir = ($newDeer.dir + 3) % 4
        $newDeer.score += 1000
        $delta = $deltas[$newdeer.dir]
        $infront = $newdeer.coord + $delta
        $infrontSpace = $map[$infront.Hash()]
        if ($infrontSpace.type -ne "#" -and $infrontSpace.lowestScore -ge ($newdeer.score + 1)) {
            $map[$newDeer.coord.Hash()].lowestScore = $newDeer.score
            $newDeer.score++
            $newDeer.coord += $delta
            $newDeer.path += $newDeer.coord
            $map[$infront.Hash()].lowestScore = $newDeer.score
            $searchSpace.Enqueue($newDeer, $newDeer.score)
        }
        if($debug % 10000 -eq 0){
            write-host "$debug checks performed, queue length:$($searchSpace.Count)"
        }
    }
    $paths = @()
    $possibleDeers | %{
        $_.path | %{
            if($_ -notin $paths){$paths += $_}
        }
    }
    $paths.count
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 45
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 64
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

