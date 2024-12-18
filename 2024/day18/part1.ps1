. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

function Solution {
    param ($solArgs)

    # Parse the data
    $data = get-content $solArgs.Path | % {
        [int]$x, [int]$y = $_ -split ","
        [coords]($y, $x)
    }

    # Generate the map with the number of corrupted bytes
    $map = New-Object "int[,]" ($solArgs.size), ($solArgs.size)
    for ($i = 0; $i -lt $solArgs.count; $i++) {
        $byte = $data[$i]
        $map[$byte.Array()] = -1
    }

    # Dijkstras to find the min steps to the end
    $start = [coords](0, 0)
    $end = [coords]( ($solArgs.size - 1), ($solArgs.size - 1))
    $totalSteps = [int32]::MaxValue
    $searchSpace = New-Object System.Collections.Queue
    $searchSpace.Enqueue($start)
    :dijk while ($searchSpace.Count) {
        $cell = $searchSpace.Dequeue()
        $cellVal = $map[$cell.Array()]
        foreach ($validNeighbour in $cell.ValidOrthNeighbours($solArgs.size, $solArgs.size)) {
            if ($validNeighbour -eq $start) { continue } #Don't go back to the start
            if ($validNeighbour -eq $end) {
                # Since Dijkstras runs on a queue, we'll always hit the end on the minimum steps,
                # so we can exit the search once we've found the end
                $totalSteps = $cellVal + 1
                break dijk
            }
            $val = $map[$validNeighbour.Array()]
            if ($val -eq -1) { continue } #Don't go into corrupted bytes
            if ($val -gt ($cellVal + 1) -or $val -eq 0) {
                $map[$validNeighbour.Array()] = $cellVal + 1
                $searchSpace.Enqueue($validNeighbour)
            }
        }
    }
    
    # Output the minimum steps to the end
    $totalSteps
}

Unit-Test  ${function:Solution} @{Path = "$PSScriptRoot/testcases/test1.txt"; size = 7; count = 12 } 22
$measuredTime = measure-command { $result = Solution @{Path = "$PSScriptRoot/input.txt"; size = 71; count = 1024 } }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

