. "$PSScriptRoot\..\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/../testcases/test1.txt"

function Solution {
    param ($Path)


    $data = (get-content $Path) -split ',' | % { [int]$_ } 

    if ($Path -match "input.txt") {
        $data[1] = 12
        $data[2] = 2
    }

    $index = 0
    while ($data[$index] -ne 99) {
        $indexes = $data[($index + 1)..($index + 3)]
        if ($data[$index] -eq 1) {
            $data[$indexes[2]] = $data[$indexes[0]] + $data[$indexes[1]]
        }
        elseif ($data[$index] -eq 2) {
            $data[$indexes[2]] = $data[$indexes[0]] * $data[$indexes[1]]
        }
        $index += 4
    }
    $data[0]

}
Unit-Test  ${function:Solution} "$PSScriptRoot/../testcases/test1.txt" 3500
$measuredTime = measure-command { $result = Solution "$PSScriptRoot/../input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

