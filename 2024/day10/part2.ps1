. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)


    $data = get-content $Path
    $width = $data[0].Length
    $height = $data.count
    $zeros = @()

    $map = New-Object "int[,]" $height, $width
    # Parse into 2D array, find each 0 and add to starting points
    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $map[$y, $x] = [int][string]$data[$y][$x]
            if ($data[$y][$x] -eq "0") {
                $zeros += [coords]($y, $x)
            }
        }
    }

    # For each, run dikstras on it, find the number of 9's
    $total = 0
    foreach ($zero in $zeros) {
        $endsReached = @{}
        $searchSpace = new-object "System.Collections.Queue"
        $searchSpace.Enqueue($zero)

        while ($searchSpace.count) {
            $space = $searchSpace.dequeue()
            foreach ($coord in $space.OrthNeighbours()) {
                if (-not $coord.Contained($height, $width)) { continue }
                if ($map[$coord.array()] -eq ($map[$space.Array()] + 1) ) {
                    if ($map[$coord.array()] -eq 9) {
                        $endsReached[$coord.hash()]++
                    }
                    else {
                        $searchSpace.Enqueue($coord)
                    }
                }
            }
        }
        $total += ($endsReached.Values | measure -sum).sum
    }
    $total

    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 81
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

