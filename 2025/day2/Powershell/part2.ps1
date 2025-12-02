. "$PSScriptRoot\..\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/..\testcases/test1.txt"

function Solution {
    param ($Path)
    
    $invalidTotal = 0
    (get-content $Path) -split "," | % {
        $start, $end = [int64[]]($_ -split "-")
        for ($val = $start; $val -le $end; $val++) {
            $string = "$val"
            if ( $string -match "^([1-9]\d*)(\1)+$" ) {
                $invalidTotal += $val
            }
        }
    }
    $invalidTotal
}

Unit-Test  ${function:Solution} "$PSScriptRoot/..\testcases/test1.txt" 4174379265
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\..\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta