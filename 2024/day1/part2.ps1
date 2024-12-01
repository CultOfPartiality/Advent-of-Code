. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$list1 = @()
	$list2 = @()

	$data = get-content $Path | % {
		$a, $b = $_ -split "   "
		$list1 += [int]$a
		$list2 += [int]$b
	}

	$list1 = $list1 | sort
	$list2 = $list2 | sort

	$total = 0
	for ($i = 0; $i -lt $list1.Count; $i++) {
		# This could be optimised
		$total += $list1[$i] * ($list2 | ?{$_ -eq $list1[$i]}).Count
	}

	$total
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 31
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

