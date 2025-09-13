. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

# Reused int computer this year
. "$PSScriptRoot\..\intComp.ps1"

function Solution {
    param ($Path)

    $data = (get-content $Path) -split ',' | % { [int]$_ } 
    $Comp = [Computer]::New($data)
    $Comp.RunComputer(1)
    $Comp.outputSignal
}
$measuredTime = measure-command { $result = Solution "$PSScriptRoot/input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

