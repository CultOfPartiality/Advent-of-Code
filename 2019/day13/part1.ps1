. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

# Reused IntCode computer this year
. "$PSScriptRoot\..\IntCodeComputer.ps1"

function Solution {
    param ($Path)
   
    $memory = (get-content $Path) -split ',' | % { [int64]$_ } 
    $ArcadeMachine = [Computer]::New($memory)
    $ArcadeMachine.RunComputer($null)

    $Screen = @{}
    $ArcadeMachine.outputBuffer | Split-Array -GroupSize 3 | % {
        $x, $y, $id = $_
        $Screen["$x,$y"] = $id
    }

    $Screen.Values | group | ? { $_.Name -eq 2 } | select -ExpandProperty Count
}

$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" } #462
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

