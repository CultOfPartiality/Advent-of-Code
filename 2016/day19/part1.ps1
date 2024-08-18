. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)
	$number = [int] (get-content $Path)

	# Working it out on paper, the formula is:
	# 	2(n-pow2)+1; where pow2 is the largest number that's of the form 2^y that is less than the number in question

	$pow = 1
	while ($pow -lt $number) {
		$pow *= 2
	}
	2 * ($number - $pow / 2) + 1

}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 3
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

