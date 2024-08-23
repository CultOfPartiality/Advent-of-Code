. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)
    
    $instructions = get-content $Path | % { [int]$_ }

    $pointer = 0
    $steps = 0
    while ($pointer -lt $instructions.Count) {
        $jump = $instructions[$pointer]
        $instructions[$pointer]++
        $pointer += $jump
        $steps++
    }
    $steps
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 5
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

