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

    # Calculate for each scanner if we'll get caught. Being caught is if the time it takes us to get there is a mulitple of it's cycle time
    $scanners | ? { ($_.depth % $_.cycle) -eq 0 } | % { $_.depth * $_.range } | measure -Sum | select -ExpandProperty Sum
   
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 24
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

