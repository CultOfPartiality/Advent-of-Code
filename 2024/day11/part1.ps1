. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
    param ($Path)

    # Don't bother keeping track of the order, just keep track of how many of 
    # each stone type we have. This reduced the work needed, as we're just moving
    # the group of stones around to different numbers

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
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 55312
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

