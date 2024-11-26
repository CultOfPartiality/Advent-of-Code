. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)


    $SerialNumber = [int] (get-content $Path)
    $grid = New-Object "int[,]" 301, 301

    function calc-power {
        param($x, $y, $SerialNumber)
        $rackID = $x + 10
        $power = ($rackID * $y + $SerialNumber) * $rackID
        [math]::Truncate( ($power % 1000) / 100 ) - 5
    }

    #calc powers
    for ($x = 1; $x -lt 301; $x++) {
        for ($y = 1; $y -lt 301; $y++) {
            $grid[$x, $y] = calc-power $x $y $SerialNumber
        }
    }

    #Debug
    for ($y = 1; $y -lt 11; $y++) {
        $row = ""
        for ($x = 1; $x -lt 11; $x++) {
            $row += ([string]$grid[$x, $y]).PadLeft(2," ") + ","
        }
        write-host ($row.TrimEnd(","))
    }
    
    $bestPower = 0
    $bestPowerCoords = @()
    $bestGroupSize = 0
    #look for biggest group
    foreach ($groupsize in 1..300) {
        write-host "Checking groupsize $groupsize"
        for ($x = 1; $x -lt (301-$groupsize); $x++) {
            for ($y = 1; $y -lt (301-$groupsize); $y++) {
                $power = 0
                foreach ($dx in 0..($groupsize-1)) {
                    foreach ($dy in 0..($groupsize-1)) {
                        $power += $grid[($x + $dx), ($y + $dy)]
                    }
                }
                if ($power -gt $bestPower) {
                    $bestPower = $power
                    $bestPowerCoords = $x, $y
                    $bestGroupSize = $groupsize
                    write-host (($bestPowerCoords | % { [string]$_ } | Join-String -Separator ",") + ","+[string]$groupsize)
                }
            }
        }
    }
    ($bestPowerCoords | % { [string]$_ } | Join-String -Separator ",") + ","+[string]$groupsize
    

}
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" "90,269,16"
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" "232,251,12"
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

