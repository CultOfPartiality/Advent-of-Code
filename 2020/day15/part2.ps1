. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

#It got bad, so we're jumping over to C#
Add-Type (Get-Content -raw "$PSScriptRoot\csharp_solver.cs")

function Solution {
    param ($Path)

    [int[]]$startingNumbers = (get-content $Path) -split ","
    [CalcGame]::Run($startingNumbers,30000000)
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 175594
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

