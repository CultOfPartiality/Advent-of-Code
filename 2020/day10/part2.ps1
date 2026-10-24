. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $adaptors = [int[]](get-content $Path) | Sort-Object

    $adaptors = @(0) + $adaptors + ($adaptors[-1] + 3)
    $numberOfSteps = @{}

    $numberofSteps[0] = 1

    for ($i = 1; $i -lt $adaptors.Count; $i++) {
        $adaptor = $adaptors[$i]
        $sourceAdaptors = $adaptors[[math]::Max(0,$i-3)..($i-1)] | ?{$adaptor - $_ -le 3 }
        $numberOfSteps[$adaptor] = $sourceAdaptors | %{$numberOfSteps[$_]} | Sum-Array
    }

    $numberOfSteps[$adaptors[-1]]
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 8
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 19208
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

