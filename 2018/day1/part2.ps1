. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $list = (get-content $Path) | % { [int]$_ }
    $index = 0
    $freq = 0

    $prev = @{}

    while ( -not ($prev.ContainsKey($freq)) ) {
        $prev[$freq] = $true
        $freq += $list[$index]
        $index = ($index + 1) % $list.Count
    }

    $freq

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 10
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

