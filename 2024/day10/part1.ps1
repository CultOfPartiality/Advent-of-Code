. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

function Solution {
    param ($Path)

    # Load the data into a 2D array, and grab all the zeros as starting locations

    $data = get-content $Path
    $width,$height = $data[0].Length , $data.count
    $zeros = @()
    $map = New-Object "int[,]" $height, $width
    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $map[$y, $x] = [int][string]$data[$y][$x]
            if ($data[$y][$x] -eq "0") {
                $zeros += [coords]($y, $x)
            }
        }
    }

    # For each zero, run dikstra's but only going up. For each 9 it reached, add that to the hash
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
        # Add to the total the number of unique 9's each trail can reach
        $total += $endsReached.Count
    }

    # Output the total
    $total
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 36
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

