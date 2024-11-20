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

    $bestPower = 0
    $bestPowerCoords = @()
    #look for biggest group
    for ($x = 1; $x -lt 299; $x++) {
        for ($y = 1; $y -lt 299; $y++) {
            $power = 0
            foreach ($dx in 0..2) {
                foreach ($dy in 0..2) {
                    $power += $grid[($x + $dx), ($y + $dy)]
                }
            }
            if ($power -gt $bestPower) {
                $bestPower = $power
                $bestPowerCoords = $x, $y
            }
        }
    }
    $bestPowerCoords | %{[string]$_} | Join-String -Separator ","
    

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" "21,61"
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

