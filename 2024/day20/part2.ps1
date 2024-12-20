. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

#The following line is for development
# $Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($arguments)


    $data = get-content $arguments.Path
    $width = $data[0].length
    $height = $data.count

    #Flood fill from the exit, to get the distance from any point to the exit, as well as the 
    #normal race time
    # Generate the map with the number of corrupted bytes
    $map = New-Object "int[,]" $height, $width
    $track = @($start)
    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $coord = [coords]($y, $x)
            switch ($data[$y][$x]) {
                '#' {
                    $map[$y, $x] = -1
                }
                'S' { $start = $coord; }
                'E' { $end = $coord }
                '.' {}
            }
        }
    }

    function print-map {
        for ($y = 0; $y -lt $height; $y++) {
            $row = ""
            for ($x = 0; $x -lt $width; $x++) {
                $row += switch ($map[$y, $x]) {
                    -1 { "#" }
                    default { "." }
                }
            }
            write-host $row
        }
    }

    $totalSteps = 0
    # Dijkstras to the path from the end to anywhere
    $searchSpace = New-Object System.Collections.Queue
    $searchSpace.Enqueue($start)
    :dijk while ($searchSpace.Count) {
        $cell = $searchSpace.Dequeue()
        $cellVal = $map[$cell.Array()]
        foreach ($validNeighbour in $cell.ValidOrthNeighbours($height, $width)) {
            if ($validNeighbour -eq $start) { continue } #Don't go back to the 'start'
            if ($validNeighbour -eq $end) {
                # Since Dijkstras runs on a queue, we'll always hit the end on the minimum steps,
                # so we can exit the search once we've found the end
                if ($totalSteps -eq 0) {
                    $totalSteps = $cellVal + 1
                }
            }
            $val = $map[$validNeighbour.Array()]
            if ($val -eq -1) { continue } #Don't go into wall
            if ($val -eq 0 -or $val -gt ($cellVal + 1)) {
                $map[$validNeighbour.Array()] = $cellVal + 1
                $track += $validNeighbour
                $searchSpace.Enqueue($validNeighbour)
            }
        }
    }

    $cheats = 0
    $dist = $arguments.dist
    $thresh = $arguments.thresh
    foreach ($step in $track) {
        $startSteps = $map[$step.array()]
        for ($y = [math]::Max(($step.row - $dist), 0); $y -le [math]::Min(($step.row + $dist), $height); $y++) {
            for ($x = [math]::Max(($step.col - $dist), 0); $x -le [math]::Min(($step.col + $dist), $width); $x++) {
                $endSteps = $map[$y, $x]
                
                #Ignore walls
                if ($endSteps -eq -1) { continue }
                #Ignore going backwards
                if ($endSteps -le $startSteps) { continue }
                
                #Make sure the manhattan distance is valid
                $cheatDist = $step.Distance(([coords]($y, $x)))
                if ($cheatDist -gt $dist) { continue }
                
                #Need to save at least the threshold
                $nonCheatDist = $endSteps - $startSteps
                if ( ($nonCheatDist - $cheatDist) -ge $thresh) {
                    $cheats++
                }
            }
        }
    }
    $cheats
}
Unit-Test  ${function:Solution} @{Path = "$PSScriptRoot/testcases/test1.txt"; thresh = 2; dist = 2 } 44
Unit-Test  ${function:Solution} @{Path = "$PSScriptRoot/input.txt"; thresh = 100; dist = 2 } 1459
Unit-Test  ${function:Solution} @{Path = "$PSScriptRoot/testcases/test1.txt"; thresh = 50; dist = 20 } 285
$measuredTime = measure-command { $result = Solution @{Path = "$PSScriptRoot\input.txt"; thresh = 100; dist = 20 } }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
if ($result -in (1015795)) { write-host "1015795 is too low" -ForegroundColor Red }

