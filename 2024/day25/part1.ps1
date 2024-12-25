. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
	param ($Path)

	# Split lines into groups of 8, parse the keys and locks into numbers arrays, then check the
	# combos of locks and keys. If a column adds up to more than 5, then it's invalid.

	$data = get-content $Path | Split-Array -GroupSize 8

	$keys = $data | ? { $_[6] -eq "#####" } | % {
		$keydata = $_
		$pinNums = foreach ($col in 0..4) { (($keydata | % { $_[$col] }) -eq '#').count - 1 }
		, $pinNums
	}

	$locks = $data | ? { $_[0] -eq "#####" } | % {
		$tumblerdata = $_
		$tumblerNums = foreach ($col in 0..4) { (($tumblerdata | % { $_[$col] }) -eq '#').count - 1 }
		, $tumblerNums
	}

	$combos = 0
	foreach ($key in $keys) {
		$combos +=
		$locks.where({
			$_[0]+$key[0] -le 5 -and
			$_[1]+$key[1] -le 5 -and
			$_[2]+$key[2] -le 5 -and
			$_[3]+$key[3] -le 5 -and
			$_[4]+$key[4] -le 5
		}).count
	}

	#Output the valid lock/key combos
	$combos
}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 3
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

