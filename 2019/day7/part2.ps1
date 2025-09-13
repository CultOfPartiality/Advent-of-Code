. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

# Reused IntCode computer this year
. "$PSScriptRoot\..\IntCodeComputer.ps1"

function Solution {
	param ($Path)

	$memory = (get-content $Path) -split ',' | % { [int]$_ } 

	$phaseSettings = 5..9
	$possibleSettings = Get-AllPermutations($phaseSettings)
	$best = 0
	foreach ($perm in $possibleSettings) {
		
		$computers = 0..4 | %{[Computer]::New($memory)}
		
		#Prime computers with the settings as the first input
		0..4 | %{$computers[$_].RunComputer($perm[$_])}

		#Run computers sequentially until they're done
		$comp = 0
		$inputSignal = 0
		while(!$computers[4].complete){
			$computers[$comp].RunComputer($inputSignal)
			$inputSignal = $computers[$comp].outputSignal
			$comp = ($comp+1) % 5
		}
		$best = [math]::max($best, $computers[4].outputSignal)
	}
	$best
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test4.txt" 139629729
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test5.txt" 18216
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

