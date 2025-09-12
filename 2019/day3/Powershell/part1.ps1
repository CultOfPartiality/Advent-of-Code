. "$PSScriptRoot\..\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\..\UsefulStuff.ps1"

function Solution {
    param ($Path)

    $wires = get-content $Path | % { , ($_ -split ",") }

    $Steps = @{}
    $Intersections = @()
    $bit = 1 #Each round sets a bit, to avoid counting self intersections
    foreach ($wire in $wires) {
        $coords = 0, 0 # Y,X, +ve is up and to the right
        foreach ($step in $wire) {
            for ($len = [int]$step.Substring(1); $len -gt 0; $len--) {
                switch ($step[0]) {
                    "U" { $coords[0]++ }
                    "D" { $coords[0]-- }
                    "R" { $coords[1]++ }
                    "L" { $coords[1]-- }
                }
                $hash = "$($coords[0]),$($coords[1])" #HOTSPOT?
                $Steps[$hash] = $Steps[$hash] -bor $bit
                if($Steps[$hash] -eq 3){ $Intersections += $coords | Manhattan-Distance }
            }
        }
        $bit *= 2
    }

    ($Intersections | Sort-Object)[0]
}
Unit-Test  ${function:Solution} "$PSScriptRoot/../testcases/test1.txt" 6
Unit-Test  ${function:Solution} "$PSScriptRoot/../testcases/test2.txt" 159
Unit-Test  ${function:Solution} "$PSScriptRoot/../testcases/test3.txt" 135
$measuredTime = measure-command {$result = Solution "$PSScriptRoot/../input.txt"}
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

