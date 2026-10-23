. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $adaptors = [int[]](get-content $Path) | Sort-Object

    $adaptors = @(0) + $adaptors + ($adaptors[-1] + 3)

    $1diff = 0
    $3diff = 0

    1..($adaptors.count - 1) | % {
        switch ($adaptors[$_] - $adaptors[$_ - 1]) {
            1 { $1diff++ }
            3 { $3diff++ }
        }
    }

    $1diff * $3diff
    # $SearchSpace = [System.Collections.Stack]::new()
    # $SearchSpace.Push([PSCustomObject]@{
    #     CurrentStack = @(0)
    #     Adaptors = $adaptors
    # })

    # while($SearchSpace.Count){
    #     $state = $SearchSpace.pop()

    #     $possibleAdaptors = $state.Adaptors | ?{$_ }
    # }


}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 35
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 220
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

