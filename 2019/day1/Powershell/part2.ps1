. "$PSScriptRoot\..\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\..\UsefulStuff.ps1"

#The following line is for development
# $Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)
    
    function Calc-Fuel($mass){[math]::Floor($mass / 3) - 2}

    get-content $Path | % {
        $fuel = Calc-Fuel($_)
        $fuelTotal = $fuel
        while($fuel -gt 0){
            $fuel = Calc-Fuel($fuel)
            $fuelTotal += [math]::Max($fuel,0)
        }
        $fuelTotal
    } | Measure-Object -Sum | Select -ExpandProperty Sum
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/../testcases/test1.txt" 51316
$measuredTime = measure-command { $result = Solution "$PSScriptRoot/../input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
