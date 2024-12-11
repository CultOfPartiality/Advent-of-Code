. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)


    $stones = @{}
    (get-content $Path) -split " " | % {
        $num = [int]$_
        $stones[$num]++
    }

    1..25 | % {
        $newStones = @{}
        foreach($value in $stones.Keys){
            switch ($value) {
                0 { $newStones[1] += $stones[$value] }
                { $value -gt 9 -and [math]::Ceiling([math]::Log10($value+1)) % 2 -eq 0 } {
                    $temp = [string]$value
                    $val1 = [int]$temp.Substring(0,$temp.Length/2)
                    $val2 = [int]$temp.Substring($temp.Length/2,$temp.Length/2)
                    $newStones[$val1] += $stones[$value]
                    $newStones[$val2] += $stones[$value]
                }
                Default { $newStones[$value*2024] += $stones[$value] }
            }
        }
        $stones = $newStones
    }

    ($stones.Values | measure -sum).sum
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 55312
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

