. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$rows = get-content $Path | % { , $_.ToCharArray() }
	[int64]$total = 0
	
	$numbers = @()
	for ($col = $rows[0].Count - 1; $col -ge 0; $col--) {
		$number = ""
		foreach ($row in 0..($rows.Count - 2)) {
			$number += $rows[$row][$col]
		}
		if ($number -notmatch "\d") { continue }

		$numbers += [int64]$number
		if ($rows[-1][$col] -eq " ") { continue }
	
		$op = $rows[-1][$col]
		$thisSum = $numbers[0]
		foreach ($number in $numbers[1..($numbers.Count - 1)]) {	
			if ($op -eq "*") {
				$thisSum *= $number
			}
			else {
				$thisSum += $number
			}
		}
		$total += $thisSum
		$numbers = @()
	}

	$total
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 3263827
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta