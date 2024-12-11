. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
    param ($Path)

    # Same as part 1, since this is already optimised somewhat

    $stones = @{}
    (get-content $Path) -split " " | % {
        $num = [int]$_
        $stones[$num]++
    }

    1..75 | % {
        $newStones = @{}
        foreach($value in $stones.Keys){
            switch ($value) {
                0 { $newStones[1] += $stones[$value] }
                { $value -gt 9 -and [math]::Ceiling([math]::Log10($value+1)) % 2 -eq 0 } {
                    $numOfChars = [math]::Ceiling([math]::Log10($value+1))
                    $splitter = [math]::Pow(10,($numOfChars/2))
                    $newStones[[math]::Truncate($value / $splitter)] += $stones[$value]
                    $newStones[$value % $splitter] += $stones[$value]
                }
                Default { $newStones[$value*2024] += $stones[$value] }
            }
        }
        $stones = $newStones
    }


    ($stones.Values | measure -sum).sum
    
}
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

