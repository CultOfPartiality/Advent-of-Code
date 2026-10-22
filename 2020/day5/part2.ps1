. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $seats = get-content $Path | % {
        [Convert]::ToUInt16( ($_ -replace "L|F", "0" -replace "B|R", "1" -join "") , 2)
    } | sort

    for($index = 0; $index -lt $seats.Count; $index++){
        if($seats[$index+1] - $seats[$index] -gt 1){
            return $seats[$index]+1
        }
    }   
}
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

