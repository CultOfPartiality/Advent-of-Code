. "$PSScriptRoot\..\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\..\UsefulStuff.ps1"

# Reused IntCode computer this year
. "$PSScriptRoot\..\..\IntCodeComputer.ps1"


function Solution {
    param ($Path)

    $data = (get-content $Path) -split ',' | % { [int]$_ }
    if ($Path -match "input.txt") {
        $data[1] = 12
        $data[2] = 2
    }

    $Comp = [Computer]::New($data)
    $Comp.RunComputer($null)
    $Comp.memory[0]

}
Unit-Test  ${function:Solution} "$PSScriptRoot/../testcases/test1.txt" 3500
$measuredTime = measure-command { $result = Solution "$PSScriptRoot/../input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

