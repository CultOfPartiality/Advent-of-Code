. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    # Parse coordinates
    $id = [int][char]"a"
    $rawData = get-content $Path
    $data = $rawData | % {
        $col, $row = $_ -split ", "
        [PSCustomObject]@{
            ID     = $id
            col    = [int]$col
            row    = [int]$row
            coords = @([int]$col, [int]$row)
        }
        $id++
    }


    # Find the "outermost" coordinates. These define the area that we actually need to check as the bounded regions must be within
    $colLimit = ($data.col | measure -Minimum -Maximum | select -ExpandProperty Maximum) + 1
    $rowLimit = ($data.row | measure -Minimum -Maximum | select -ExpandProperty Maximum) + 1

    $area = New-Object 'Object[,]' ($colLimit), ($rowLimit)
    function print-area {
        write-host
        for ($row = 0; $row -lt $rowLimit; $row++) {
            for ($col = 0; $col -lt $colLimit; $col++) {
                switch ($area[$col, $row].ID) {
                    $null { write-host -NoNewline -ForegroundColor DarkGray "-" }
                    -1 { write-host -NoNewline -ForegroundColor DarkGray "." }
                    Default {
                        if ("$col, $row" -in $rawData) {
                            write-host ([char] ($area[$col, $row].ID - 32)) -NoNewline
                        }
                        else {
                            write-host ([char]$area[$col, $row].ID) -NoNewline -ForegroundColor DarkGray
                        }
                    }
                }
            }
            write-host
        }
    }


    $nextSearchSpace = New-Object "System.Collections.Queue"
    foreach ($point in $data) {
        $area[$point.coords] = [PSCustomObject]@{
            ID    = $point.ID
            Round = 0
        }
        $nextSearchSpace.Enqueue($point)
    }
    
    $round = 0
    while ($nextSearchSpace.count) {
        $searchSpace = $nextSearchSpace.Clone()
        $nextSearchSpace.Clear()
        $round++
        while ($searchSpace.count) {
            # Generate a point in each direction
            $point = $searchSpace.Dequeue()
            foreach ($delta in ((1, 0), (-1, 0), (0, 1), (0, -1))) {
                $newCoords = ($point.col + $delta[0]),($point.row + $delta[1])
                if( (($newCoords -lt 0).count -gt 0) -or ($newCoords[0] -ge $colLimit) -or ($newCoords[1] -ge $rowLimit) ){continue}
                $testLocation = $area[$newCoords]
                # If nothing else has visited here claim it
                if ($null -eq $testLocation.id) {
                    $area[$newCoords] = [PSCustomObject]@{
                        ID    = $point.ID
                        Round = $round
                    }
                    $nextSearchSpace.Enqueue([PSCustomObject]@{
                            ID     = $point.id
                            col    = $newCoords[0]
                            row    = $newCoords[1]
                            coords = @($newCoords[0], $newCoords[1])
                        })
                }
                # If someone else got here on the same round, mark this as invalid 
                elseif ( ($testLocation.round -eq $round) -and ($point.id -ne $testLocation.ID) ) {
                    $area[$newCoords].ID = -1
                }
            }
        }
        #print-area
    }


    # Any region touching the edge will be infinite
    $edgeData = foreach ($row in 0..($rowLimit-1)) {
        $area[0, $row].id
        $area[($colLimit-1), $row].id
    }
    $edgeData += foreach ($col in 0..($colLimit-1)) {
        $area[$col, 0].id
        $area[$col, ($rowLimit-1)].id
    }
    $edgeData = $edgeData | select -Unique

    # Count up all areas, remove any infinites, then return the largest
    ($area | ? { $_.ID -notin $edgeData } | ? { $_ -ne -1 } | group ID | sort Count -Descending)[0].Count


    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 17
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
Write-Host "5080 is too high" -ForegroundColor DarkGray

