. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
    param ($Path)

    # Regular expression to get all valid operations
    $data = get-content $Path | select-string -AllMatches "mul\((\d*),(\d*)\)|(do\(\)|don't\(\))"
    
    # Keep track of the total, and whether we're currently enabled or disabled
    # Run each operation (if enabled), adding to the total
    $total = 0
    $do = $true
    $data.Matches | % {
        if ($_.Value -eq "do()") {
            $do = $true
        }
        elseif ($_.Value -eq "don't()") {
            $do = $false
        }
        elseif ($do) {
            $val1 = [int]$_.Captures[0].Groups[1].Value
            $val2 = [int]$_.Captures[0].Groups[2].Value
            $total += $val1 * $val2
        }
    }

    # Output the total
    $total
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 48
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

