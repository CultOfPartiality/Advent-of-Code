. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $scanners = get-content $Path | % {
        [int]$depth, [int]$range = $_ -split ": "
        [PSCustomObject]@{
            depth = $depth
            range = $range
            cycle = (2 * $range - 2)
        }
    }

    # Brute force = No
    # $caught = $true
    # $delay = 0
    # while($caught){
    #     $delay++
    #     $caught = ($scanners | ? { (($_.depth + $delay) % $_.cycle) -eq 0 } ).Count 
    # }
    # $delay

    # Delay count can't be 0
    # Delay count can't be a multiple of 4      (10 % 4 != 0)
    # Delay count +1 can't be a multiple of 2   (11 % 2 != 0)
    # Delay count +4 can't be a multiple of 6   (14 % 6 != 0)
    # Delay count +6 can't be a multiple of 6   (16 % 6 != 0)
    # head [x | x <- [1..] , mod x 4 > 0, mod (x+1) 2 > 0, mod (x+4) 6 > 0, mod (x+6) 6 > 0] in Haskell...
    #1..([int32]::MaxValue) | ?{$_%4 -ne 0} | ?{($_+1)%2 -ne 0}  | ?{($_+4)%6 -ne 0} | ?{($_+6)%6 -ne 0} | select -first 1

    $executionString = "1..([int32]::MaxValue) "
    foreach ($scanner in $scanners) {
        $executionString += ' | ?{ ($_+' + $scanner.depth + ') % ' + $scanner.cycle + ' -ne 0} '
    }
    $executionString += " | select -first 1 "

    Invoke-Expression $executionString

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 10
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

