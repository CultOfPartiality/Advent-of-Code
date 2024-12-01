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

	# Multiply each entry with the number of times it occured in the second list, and add to the total
	$total = 0
	for ($i = 0; $i -lt $list1.Count; $i++) {
		# Using array lists was a ~20x improvement, and checking is was contained before looping over the list saved an extra little bit
		if($list2.Contains($list1[$i])){
			$total += $list1[$i] * ($list2 -eq $list1[$i]).Count
		}
	}

	# Output the solved total
	$total
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 31
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

