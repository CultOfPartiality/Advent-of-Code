. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
	param ($Path)

	# Parse the two lists into sorted arrays
	$list1 = New-Object System.Collections.ArrayList
	$list2 = New-Object System.Collections.ArrayList
	get-content $Path | % {
		$a, $b = $_ -split "   "
		[void]$list1.Add([int]$a)
		[void]$list2.Add([int]$b)
	}
	$list1.Sort()
	$list2.Sort()

	# Add the distance between each entry to the total
	$total = 0
	for ($i = 0; $i -lt $list1.Count; $i++) {
		$total += [math]::abs($list1[$i] - $list2[$i])
	}

	# Output the solved total
	$total
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 11
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

