. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)
    $data = (get-content $Path) -split "," | % {
        if ($_ -match "-") {
            $start, $end = [int64[]]($_ -split "-")
        }
        else {
            $start = [int] $_
            $end = $start
        }
        , @($start, $end)
    }

    $invalidTotal = 0
    foreach ($range in $data) {
        $start, $end = $range
        for ($val = $start; $val -le $end; $val++) {
            $string = "$val"
            if ( $string -match "^([1-9]\d*)\1$" ) {
                # write-host "Invalid number: $string"
                $invalidTotal += $val
            }
        }
    }
    $invalidTotal
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 1227775554
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta