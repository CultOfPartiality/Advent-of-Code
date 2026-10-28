. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    [int[]]$startingNumbers = (get-content $Path) -split ","

    $roundNumberWasSaidLast = @{}
    $turn = 0
    $startingNumbers | % {
        $turn++
        $roundNumberWasSaidLast[$_] = @($turn)
    }
    $lastSaid = $startingNumbers[-1]

    while ($turn -lt 2020) {
        $turn++
        if ($roundNumberWasSaidLast[$lastSaid].Count -eq 1) {
            $lastSaid = 0
        }
        else {
            $lastSaid = $roundNumberWasSaidLast[$lastSaid][-1] - $roundNumberWasSaidLast[$lastSaid][-2]
        }
        $roundNumberWasSaidLast[$lastSaid] += @($turn)
    }
    $lastSaid
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 436
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

