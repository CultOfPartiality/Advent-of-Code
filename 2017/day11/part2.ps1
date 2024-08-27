. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$data = "ne,ne,s,s,sw,se,n"

function Solution {
	param ($data)

	$data = $data -split ","
	function Calc-Distance {
		param($n, $ne, $nw)

		# If ne and nw are both the same direction then we can balance
		if ([math]::sign($ne) -eq [math]::sign($nw)) {
			$vert = $n + [math]::MinMagnitude($ne, $nw)
			$diag = $ne - $nw
			$total = [math]::abs($vert) + [math]::abs($diag)
		}
		# If n is zero, (and we know ne and nw are different signs and thus go in the same E or W direction),
		# then we can just add the magnitudes of ne and nw 
		elseif ($n -eq 0) {
			$total = [math]::abs($ne) + [math]::abs($nw)
		}
		# If n is going in the same direction as the vertical component of ne and nw, then they add with no overlap
		elseif ([math]::sign($ne + $nw) -eq [math]::sign($n)) {
			$vert = $n + [math]::MinMagnitude($ne, $nw)
			$diag = $ne - $nw
			$total = [math]::abs($vert) + [math]::abs($diag)
		}
		# Else, the north component subtracts from that from the ne/nw
		else {
			$vertOffset = $ne + $nw
			$vert = $n
			if ([math]::abs($n) -le [math]::abs($vertOffset)) {
				$total = [math]::abs($ne + $nw)
			}
			else {
				$total = [math]::abs([math]::MaxMagnitude($vert, $vertOffset))
			}
		}
		$total
	}

	# Sigh, guess we work it out the hard way for part 2
	$n = 0
	$ne = 0
	$nw = 0
	$stepsAway = 0
	
	foreach ($dir in $data) {
		switch ($dir) {
			"n" { $n++ }
			"s" { $n-- }
			"ne" { $ne++ }
			"sw" { $ne-- }
			"nw" { $nw++ }
			"se" { $nw-- }
		}
		$stepsAway = [Math]::Max($stepsAway, (Calc-Distance $n $ne $nw))
	}
	$stepsAway
}


# Unit-Test  ${function:Solution} "se,sw,se,sw,sw,s" 4
# Unit-Test  ${function:Solution} "se,sw,se,sw,sw,n" 2
# Unit-Test  ${function:Solution} "ne,ne,ne" 3
# Unit-Test  ${function:Solution} "ne,ne,sw,sw" 0
# Unit-Test  ${function:Solution} "ne,ne,s,s" 2
# Unit-Test  ${function:Solution} "ne,ne,s,s,s" 3
# Unit-Test  ${function:Solution} "ne,ne,ne,s,s" 3
# Write-Host "Part 1: 231 is too low" -ForegroundColor DarkGray
$measuredTime = measure-command { $result = Solution (Get-Content "$PSScriptRoot\input.txt") }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

