. "$PSScriptRoot\..\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\..\UsefulStuff.ps1"

#The following line is for development
# $Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)
    
    get-content $Path | % { [math]::Floor($_ / 3) - 2 } | Measure-Object -Sum | Select -ExpandProperty Sum
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/../testcases/test1.txt" 34241
$measuredTime = measure-command { $result = Solution "$PSScriptRoot/../input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

