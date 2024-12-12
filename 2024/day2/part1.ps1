. "$PSScriptRoot\..\..\Unit-Test.ps1"

function Solution {
    param ($Path)

    # For each list, check the following:
    #   All items are increasing/decreasing
    #   No jump is bigger than 3
    #   No jump is smaller than 1 (i.e. repeated number)
    # 
    # We're keeping track of if the array is increasing or decreasing, and return the OR of those
    # outcomes. However if we see an invalid jump, we exit early
    
    $data = get-content $Path | % { , [System.Collections.ArrayList]($_ -split " " | % { [int]$_ }) }

    $safe = foreach ($list in $data) {
        $rising = $falling = $true
        for ($i = 1; $i -lt $list.Count; $i++) {
            $diff = [Math]::ABS($list[$i] - $list[$i - 1])
        
            if ( $diff -gt 3 -or $diff -lt 1) {
                $rising = $false
                $falling = $false
                break
            }
        
            if ($list[$i] -lt $list[$i - 1]) {
                $rising = $false
            }
            if ($list[$i] -gt $list[$i - 1]) {
                $falling = $false
            }
        }
        $rising -or $falling
    }
    
    # Output the number of "safe" sequences
    ($safe -eq $true).Count
}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 2
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

