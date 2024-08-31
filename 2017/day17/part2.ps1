. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$StepCount = 3

# Since 0 is always at the start, just keep track of if a value is inserted at index 1.
# No need to run the actual buffer up
function Solution {
	param ($StepCount)

	$index = 0
	$zeroIndex = 0
	$valueAfterZero = $null
	for ($i = 1; $i -le 50000000; $i++) {
		$index = ($index + $StepCount) % $i + 1
		if($index -eq 1){
			$valueAfterZero = $i
		}
		if($i%1000000 -eq 0){
			write-host "$i indexes added"
		}
	}
	$valueAfterZero
	
}
# Unit-Test  ${function:Solution} 3 638
$measuredTime = measure-command { $result = Solution 312 }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

