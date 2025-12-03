. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)


    $data = get-content $Path
    $total = 0
    foreach ($bank in $data) {
        $batteries = $bank.ToCharArray() | % { [int]"$_" }
        $firstBat = [int]($batteries[0..($batteries.Count - 2)] | Measure-Object -Maximum).Maximum
        $secondBat = ($batteries[ ($batteries.IndexOf($firstBat) + 1)..($batteries.Count - 1) ] | Measure-Object -Maximum).Maximum

        $bestBatCombo = $firstBat * 10 + $secondBat
        $total += $bestBatCombo
    }
    $total
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 357
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

