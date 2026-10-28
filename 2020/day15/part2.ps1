. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test_0.txt"

# function Solution {
#     param ($Path)

[int[]]$startingNumbers = (get-content $Path) -split ","

$roundNumberWasSaidLast = @{}
$turn = 0
$startingNumbers | % {
    $turn++
    $roundNumberWasSaidLast[$_] = @($turn)
}
$lastSaid = $startingNumbers[-1]
$numbersInOrder = $startingNumbers

while ($turn -lt 100) {
    $turn++
    if ($roundNumberWasSaidLast[$lastSaid].Count -eq 1) {
        $lastSaid = 0
    }
    else {
        $lastSaid = $roundNumberWasSaidLast[$lastSaid][-1] - $roundNumberWasSaidLast[$lastSaid][-2]
    }
    $roundNumberWasSaidLast[$lastSaid] += @($turn)
    $numbersInOrder += $lastSaid
}
$lastSaid
# }
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 175594
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

