. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
    param ($Path)

    # Regular expression to get all valid operations
    $data = get-content $Path | select-string -AllMatches "mul\((\d*),(\d*)\)|(do\(\)|don't\(\))"
    
    # Run each operation, adding to the total
    $total = 0
    $data.Matches | % {
        $val1 = [int]$_.Captures[0].Groups[1].Value
        $val2 = [int]$_.Captures[0].Groups[2].Value
        $total += $val1 * $val2
    }

    # Output the total
    $total
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 161
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

