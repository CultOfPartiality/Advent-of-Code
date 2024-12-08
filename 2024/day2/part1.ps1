. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)


    $data = get-content $Path | % { , [System.Collections.ArrayList]($_ -split " " | % { [int]$_ }) }

    $safe = foreach ($list in $data) {
        $rising = $true
        $falling = $true
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
    ($safe -eq $true).Count
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 2
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

