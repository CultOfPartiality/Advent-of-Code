. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

#The following line is for development
$solArgs = @{Path = "$PSScriptRoot/testcases/test1.txt"; size = 7; count = 12 }

function Solution {
    param ($solArgs)

    # Binary search through the possible corrupted maps (based on number of bytes) until we find the
    # index that first byte that blocks the path completely. Map generation is a function of byte 
    # count, and the dijkstras path checking funciton returns whether the path is complete or not.

    # Both the path searching and the map generation are the same as part 1, except in a 1D array.
    # It was only after that I realised passing a 2D array into a function requires the function param
    # to be explicitly defined as a 2D array.

    $data = get-content $solArgs.Path | % {
        [int]$x, [int]$y = ($_ -split ",") -as [int[]]
        [coords]($y, $x)
    }

    function generate-map($count) {
        $map = New-Object "int[]" ($solArgs.size * $solArgs.size)
        for ($i = 0; $i -lt $count; $i++) {
            $byte = $data[$i]
            $map[$byte.OneDimIndex($solArgs.size)] = -1
        }
        return $map
    }

    function Check-Path($origMap) {
        $map = $origMap.Clone()
        $start = [coords](0, 0)
        $end = [coords]( ($solArgs.size - 1), ($solArgs.size - 1))
        $totalSteps = [int32]::MaxValue
        $searchSpace = New-Object System.Collections.Queue
        $searchSpace.Enqueue($start)
        :dijk while ($searchSpace.Count) {
            $cell = $searchSpace.Dequeue()
            $cellVal = $map[$cell.OneDimIndex($solArgs.size)]
            foreach ($validNeighbour in $cell.ValidOrthNeighbours($solArgs.size, $solArgs.size)) {
                if ($validNeighbour -eq $start) { continue } #Don't go back to the start
                if ($validNeighbour -eq $end) {
                    $totalSteps = $cellVal + 1
                    break dijk
                } #We've reached the end
                $val = $map[$validNeighbour.OneDimIndex($solArgs.size)]
                if ($val -eq -1) { continue } #Don't go into corrupted bytes
                if ($val -gt ($cellVal + 1) -or $val -eq 0) {
                    $map[$validNeighbour.OneDimIndex($solArgs.size)] = $cellVal + 1
                    $searchSpace.Enqueue($validNeighbour)
                }
            }
        }
        $totalSteps -ne [int32]::MaxValue
    }

    #Binary search, starting in between the part 1 byte count we know works, and all the bytes
    $minCount = $solArgs.Count
    $maxCount = $data.Count
    while ($minCount -ne $maxCount) {
        $currentCheck = [math]::floor(($maxCount - $minCount) / 2) + $minCount
        write-host "Checking $currentCheck, current range [$minCount,$maxCount]"
        $map = generate-map $currentCheck
        if (Check-Path $map) { $minCount = $currentCheck + 1}
        else {$maxCount = $currentCheck}
    }

    #Output the coords of the byte that blocks the path to the exit
    $byte = $data[$minCount - 1]
    "$($byte.col),$($byte.row)"

}
Unit-Test  ${function:Solution} @{Path = "$PSScriptRoot/testcases/test1.txt"; size = 7; count = 12 } "6,1"
$measuredTime = measure-command { $result = Solution @{Path = "$PSScriptRoot/input.txt"; size = 71; count = 1024 } }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

