. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $entries = [int[]] (get-content $Path)
    foreach($entry in $entries){
        $other = 2020 - $entry
        if($entries.Contains($other)){
            return ($entry * $other)
        }
    }
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 514579
$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
