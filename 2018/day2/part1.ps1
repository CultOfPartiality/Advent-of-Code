. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)
	
	$data = get-content $Path | % { , ($_.ToCharArray() | group) }

	$twos = 0
	$threes = 0

	$data | % {
		$counts = $_ | % { $_.count }
		if ($counts -contains 2) { $twos++ }
		if ($counts -contains 3) { $threes++ }
	}

	$twos * $threes

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 12
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

