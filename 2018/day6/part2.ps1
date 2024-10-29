. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$TestInput = @{Path = "$PSScriptRoot/testcases/test1.txt"; Distance = 32 }

function Solution {
    param ($TestInput)

    $Path = $TestInput.Path
    $TestDistance = $TestInput.Distance

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

    $area = New-Object 'int64[,]' ($colLimits.Maximum + 1), ($rowLimits.Maximum + 1)
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
            $sumOfDistances = $data | % { ([math]::abs($_.col - $col) + [math]::abs($_.row - $row)) } | measure -Sum 
            $area[$col, $row] = $sumOfDistances.Sum
        }
    }

    # Count up locations where distance is less than required min
    ($area | ? { $_ -lt $TestDistance }).Count
    
}
Unit-Test  ${function:Solution} @{Path = "$PSScriptRoot/testcases/test1.txt"; Distance = 32 } 16
$measuredTime = measure-command { $result = Solution @{Path = "$PSScriptRoot/input.txt"; Distance = 10000 } }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

