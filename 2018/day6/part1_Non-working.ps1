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
            ID  = $id
            col = [int]$col
            row = [int]$row
        }
        $id++
    }


    # Find the "outermost" coordinates. These define the area that we actually need to check as the bounded regions must be within
    $colLimits = $data.col | measure -Minimum -Maximum
    $colLimit = ($data.col | measure -Minimum -Maximum | select -ExpandProperty Maximum) + 1
    $rowLimits = $data.row | measure -Minimum -Maximum
    $rowLimit = ($data.row | measure -Minimum -Maximum | select -ExpandProperty Maximum) + 1

    $area = New-Object 'int32[,]' ($colLimits.Maximum + 1), ($rowLimits.Maximum + 1)
    function print-area {
        write-host
        for ($row = 0; $row -lt $rowLimits.Maximum + 1; $row++) {
            for ($col = 0; $col -lt $colLimits.Maximum + 1; $col++) {
                switch ($area[$col, $row]) {
                    0 { write-host -NoNewline -ForegroundColor DarkGray "-" }
                    -1 { write-host -NoNewline -ForegroundColor DarkGray "." }
                    Default {
                        if ("$col, $row" -in $rawData) {
                            write-host ([char] ($area[$col, $row] - 32)) -NoNewline
                        }
                        else {
                            write-host ([char]$area[$col, $row]) -NoNewline -ForegroundColor DarkGray
                        }
                    }
                }
            }
            write-host
        }
    }

    # For each point in the area, calculate which point is closest
    for ($col = 0; $col -lt $colLimit; $col++) {
        for ($row = 0; $row -lt $rowLimit; $row++) {
            $distances = $data | % { , ($_.ID, ([math]::abs($_.col - $col) + [math]::abs($_.row - $row)) ) } | sort { $_[1] }
            $area[$col, $row] = ($distances[0][1] -eq $distances[1][1]) ? -1 : $distances[0][0]
        }
    }

    # Any region touching the edge will be infinite
    $edgeData = foreach ($row in 0..$rowLimit) {
        $area[0, $row]
        $area[$colLimit, $row]
    }
    $edgeData += foreach ($col in 0..$colLimit) {
        $area[$col, 0]
        $area[$col, $rowLimit]
    }
    $edgeData = $edgeData | select -Unique

    # Count up all areas, remove any infinites, then return the largest
    ($area | ? { $_ -notin $edgeData } | ? { $_ -ne -1 } | group | sort Count -Descending)[0].Count


    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 17
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
Write-Host "5080 is too high" -ForegroundColor DarkGray

