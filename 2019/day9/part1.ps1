. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

# Reused IntCode computer this year
. "$PSScriptRoot\..\IntCodeComputer.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test3.txt"
$Path = "$PSScriptRoot/input.txt"

function Solution {
	param ($Path)

	$memory = (get-content $Path) -split ',' | % { [int64]$_ } 
	$Comp = [Computer]::New($memory)
	$Comp.RunComputer(1)
	$Comp.outputSignal   
}
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

