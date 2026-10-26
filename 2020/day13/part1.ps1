. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    [int]$time, $busesRaw = get-content $Path
    [int[]]$buses = $busesRaw -split "," | ? { $_ -ne "x" }

    $busesInfo = $buses | % {
        $nextBus = [math]::Ceiling($time / $_) * $_
        [pscustomobject]@{
            number   = $_
            waitTime = $nextBus - $time
        }
    } | sort -Property waitTime

    $busesInfo[0].waitTime * $busesInfo[0].number

   
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 295
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
