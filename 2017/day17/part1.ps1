. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$StepCount = 312

function Solution {
	param ($StepCount)

	$buffer = [System.Collections.ArrayList]@(0)
	$index = 0
	for ($i = 1; $i -le 2017; $i++) {
		$index = ($index + $StepCount) % $buffer.Count + 1
		$buffer.Insert($index, $i)
	}
	$buffer[$buffer.IndexOf(2017) + 1]
}
Unit-Test  ${function:Solution} 3 638
$measuredTime = measure-command { $result = Solution 312 }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

