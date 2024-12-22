. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test2.txt"
# $Path = "$PSScriptRoot/input.txt"

function Solution {
	param ($Path)


	$data = [int[]] (get-content $Path)


	function generate([Int64]$secretNum, $rounds) {

		$prices = New-Object int[] ($rounds+1)
		$prices[0] = $secretNum % 10
		$deltas = New-Object int[] $rounds
		$lookup = @{}

		$calcDeltas = $false
		foreach ($round in 0..($rounds-1)) {
			#Step 1
			$secretNum = (($secretNum -shl 6) -bxor $secretNum) % 16777216

			#Step 2
			$secretNum = (($secretNum -shr 5) -bxor $secretNum) % 16777216

			#Step 3
			$secretNum = (($secretNum -shl 11) -bxor $secretNum) % 16777216

			$prices[$round+1] = ($secretNum % 10)
			$deltas[$round] = ($prices[$round+1] - $prices[$round])
			if ($round -gt 2) {
				$key = $deltas[($round-3)..$round] -join ""
				if(-not $lookup.ContainsKey($key)){
					$lookup[$key] = $prices[$round+1]
				}
			}
			
		}
	
		#Return
		$lookup
	}

	# $counter = 0
	$lists = foreach ($num in $data) {
		# $counter++
		# write-host "Generating $counter"
		, (generate $num 2000)
	}


	$bestBananaSale = 0
	foreach ($d1 in -9..9) {
		
		$minDelta = $d1 -lt 0 ? (-9-$d1) : -9
		$maxDelta = $d1 -gt 0 ? ( 9-$d1) : 9
		foreach ($d2 in $minDelta..$maxDelta) {

			$combinedDelta = $d1+$d2
			$minDelta = $combinedDelta -lt 0 ? (-9-$combinedDelta) : -9
			$maxDelta = $combinedDelta -gt 0 ? ( 9-$combinedDelta) : 9
			foreach ($d3 in $minDelta..$maxDelta) {
				$combinedDelta = $d1+$d2+$d2
				$minDelta = $combinedDelta -lt 0 ? (-9-$combinedDelta) : -9
				$maxDelta = $combinedDelta -gt 0 ? ( 9-$combinedDelta) : 9
				# write-host "Working on $d1,$d2,$d3. Next range: $minDelta..$maxDelta"
				foreach ($d4 in $minDelta..$maxDelta) {
					$key = "$d1$d2$d3$d4"
					$totalBananas = 0
					foreach($list in $lists){ $totalBananas += $list[$key] }
					$bestBananaSale = [math]::max($bestBananaSale, $totalBananas)
				}
			}
		}
	}
	$bestBananaSale

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 23
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
if($result -ge 1618){write-host "Too High!" -ForegroundColor Red}

