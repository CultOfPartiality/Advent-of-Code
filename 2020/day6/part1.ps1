. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    (get-content $Path -Raw) -split ([System.Environment]::NewLine * 2) | % {
        ($_ -replace "[^a-z]", "").ToCharArray() | select -Unique | Measure-Object | select -ExpandProperty Count
    } | Sum-Array

   
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 11
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

