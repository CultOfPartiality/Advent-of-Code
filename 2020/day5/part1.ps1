. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    get-content $Path | % {
        [Convert]::ToUInt16( ($_ -replace "L|F", "0" -replace "B|R", "1" -join "") , 2)
    } | Measure-Object -Maximum | select -ExpandProperty Maximum

   
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 820
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

