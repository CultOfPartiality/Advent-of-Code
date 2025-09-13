. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

# Reused int computer this year
. "$PSScriptRoot\..\intComp.ps1"


function Solution {
	param ($Path)

	$memory = (get-content $Path) -split ',' | % { [int]$_ } 

	$phaseSettings = 0..4
	$possibleSettings = Get-AllPermutations($phaseSettings)
	$best = 0
	foreach($perm in $possibleSettings){
		$inputSignal = 0
		foreach ($amp in 0..4) {
			$Comp = [Computer]::New($memory.Clone())
			$Comp.RunComputer($perm[$amp])
			$Comp.RunComputer($inputSignal)
			$inputSignal = $Comp.outputSignal
		}
		$best = [math]::max($best,$inputSignal)
	}
	$best
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 43210
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 54321
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" 65210
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

