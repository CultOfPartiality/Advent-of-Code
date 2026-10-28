. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $mem = @{}
    [UInt64]$SetMask = 0
    [UInt64]$ClearMask = 0
    
    foreach( $row in (get-content $Path)){
        if($row -match "mask"){
            $mask = $row.Substring(7)
            $SetMask = [Convert]::ToUInt64( ($mask -replace "X", "0"), 2) #We'll use bitwise OR
            $ClearMask = [Convert]::ToUInt64( ($mask -replace "X", "1"), 2) #We'll use bitwise AND
        }
        else{
            $matchInfo = ([regex]::Match($row, "\[(\d*)\] = (\d*)"))
            $index = [int]$matchInfo.Groups[1].Value
            $value = [int]$matchInfo.Groups[2].Value
            $maskedValue = ($value -bor $SetMask) -band $ClearMask
            $mem[$index] = $maskedValue
        }
    }

    $mem.Values | Sum-Array

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 165
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
