. "$PSScriptRoot\..\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/../testcases/test1.txt"

function Solution {
    param ($Path)


    $data = get-content $Path | % {
        $rotations = [int]$_.Substring(1)
        if ($_[0] -eq "L") {
            $rotations = - $rotations
        }
        $rotations
    }

    $dial = 50
    $zeros = 0
    foreach ($rotation in $data) {
        $dial = (100 + ($dial + $rotation)) % 100
        if ($dial -eq 0) {
            $zeros++
        }
    }

    $zeros

}
Unit-Test  ${function:Solution} "$PSScriptRoot/../testcases/test1.txt" 3
$measuredTime = measure-command { $result = Solution "$PSScriptRoot/../input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

