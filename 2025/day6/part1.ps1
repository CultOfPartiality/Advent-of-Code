. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$data = get-content $Path | % { , @($_.Trim() -split "\s+") }
	
	[int64]$total = 0
	for ($i = 0; $i -lt $data[0].Count; $i++) {
		$op = $data[-1][$i]
		$thisSum = [int64]$data[0][$i]
		foreach ($param in 1..($data.Count-2)) {	
			if ($op -eq "*") {
				$thisSum *= ([int64]$data[$param][$i])
			}
			else {
				$thisSum += ([int64]$data[$param][$i])
			}
		}
		$total += $thisSum
	}
	$total
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 4277556
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta