. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    [int[]]$startingNumbers = (get-content $Path) -split ","

    $roundNumberWasSaidLast = [int[]]::new(30000000)
    $turn = 0
    $startingNumbers[0..($startingNumbers.Count - 2)] | % {
        $turn++
        $roundNumberWasSaidLast[$_] = $turn
    }
    $lastSaid = $startingNumbers[-2]
    $nextToSay = $startingNumbers[-1]

    for($turn++;$turn -lt 2020;$turn++) {
        if ($roundNumberWasSaidLast[$nextToSay]) {
            $lastSaid = $nextToSay
            $nextToSay = $turn - $roundNumberWasSaidLast[$nextToSay]
        }
        else {
            $lastSaid = $nextToSay
            $nextToSay = 0
        }
        $roundNumberWasSaidLast[$lastSaid] = $turn
    }
    $nextToSay
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 436
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

