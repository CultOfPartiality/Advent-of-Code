. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/testcases/test2.txt"

function Solution {
    param ($Path)


    $data = get-content $Path | % {
        $elements = $_ -split " "
        [PSCustomObject]@{
            Period = [int]$elements[3]
            Offset = [int]$elements[-1].TrimEnd(".")
        }
    }

    #Start at entry 1, find out the offset to get the ball in (less 1s for the ball to drop)
    $initialDelay = $data[0].Period - $data[0].Offset - 1
    #For the next entry, we delay a multiple of the first period until we can go through both
    $delay = $initialDelay
    $currentLCM = $data[0].Period
    foreach ($diskNum in 1..($data.Count - 1)) {
        $disk = $data[$diskNum]
        while ( ($disk.Offset + 1 + $diskNum + $delay) % $disk.Period -ne 0) {
            $delay += $currentLCM
        }
        $currentLCM = LCM $currentLCM $disk.Period
    }
    $delay
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 5
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 25
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\inputpart2.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

