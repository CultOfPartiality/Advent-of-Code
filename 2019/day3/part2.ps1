. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $wires = get-content $Path | % { , ($_ -split ",") }

    $Steps = @{}
    $Intersections = @()
    $WireIndex = 0 
    foreach ($wire in $wires) {
        $coords = 0, 0 # Y,X, +ve is up and to the right
        $stepcount = 0
        foreach ($step in $wire) {
            for ($len = [int]$step.Substring(1); $len -gt 0; $len--) {
                switch ($step[0]) {
                    "U" { $coords[0]++ }
                    "D" { $coords[0]-- }
                    "R" { $coords[1]++ }
                    "L" { $coords[1]-- }
                }
                $stepcount++
                $hash = "$($coords[0]),$($coords[1])" #HOTSPOT?
                if(!$Steps.ContainsKey($hash)){
                    $Steps[$hash] = [int]::MaxValue,[int]::MaxValue
                }
                $Steps[$hash][$WireIndex] = [Math]::Min($Steps[$hash][$WireIndex],$stepcount)
                if($Steps[$hash] -notcontains [int]::MaxValue){ $Intersections += $steps[$hash] | Sum-Array }
            }
        }
        $WireIndex++
    }

    ($Intersections | Sort-Object)[0]
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 30
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 610
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" 410
$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

