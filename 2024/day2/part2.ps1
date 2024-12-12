. "$PSScriptRoot\..\..\Unit-Test.ps1"

function Solution {
    param ($Path)

    # Checking the safety of a sequence is wrapped into a function. If the inital check isn't safe,
    # try again after removing an element. Keep trying with a different element removed until either
    # the sequence is "safe" or all attempts of removing a single elements have been checked 
    
    $data = get-content $Path | % { , [System.Collections.ArrayList]($_ -split " " | % { [int]$_ }) }

    function is-safe($list){
        $rising = $falling = $true
        for ($i = 1; $i -lt $list.Count; $i++) {
            $diff = [Math]::ABS($list[$i] - $list[$i - 1])
            if ( $diff -gt 3 -or $diff -lt 1) {
                $rising = $falling = $false
                break
            }
            if ($list[$i] -lt $list[$i - 1]) {
                $rising = $false
            }
            if ($list[$i] -gt $list[$i - 1]) {
                $falling = $false
            }
        }
        return ($rising -or $falling)
    }

    $safe = foreach ($list in $data) {
        $isListSafe = is-safe($list)
        $i = 0
        while((-not $isListSafe) -and $i -lt $list.Count){
            $newList = $list.clone()
            $newList.RemoveAt($i)
            $isListSafe = is-safe($newList)
            $i++
        }
        $isListSafe
    }
    
    # Output number of "safe" sequences
    ($safe -eq $true).Count
}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 4
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

