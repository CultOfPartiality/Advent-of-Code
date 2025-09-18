. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($arguments)
	$Path = $arguments.Path
	$TotalSteps = $arguments.Steps

	# Parse planet position data
	$planets = get-content $Path | % {
		$pos = $_ -replace "[<>]", "" -split ", " | % { [int]($_ -replace "[xyz=]", "") }
		[PSCustomObject]@{
			Pos = $pos
			Vel = 0, 0, 0
			dv  = 0, 0, 0
		}
	}

	$possiblePairs = Get-AllPairs(0..3)

	foreach ($step in 1..$TotalSteps) {
		#Apply Gravity
		foreach ($pair in $possiblePairs) {
			$planet1, $planet2 = $planets[$pair]
			foreach ($i in 0..2) {
				if ($planet1.Pos[$i] -eq $planet2.Pos[$i]) { continue }
				$delta = ($planet1.Pos[$i] -gt $planet2.Pos[$i]) ? 1 : -1
				$planet1.dv[$i] -= $delta
				$planet2.dv[$i] += $delta
			}
		}
		#Apply Velocity
		foreach ($planet in $planets) {
			foreach ($i in 0..2) {
				$planet.Vel[$i] += $planet.dv[$i]
				$planet.Pos[$i] += $planet.Vel[$i]
			}
			$planet.dv = 0, 0, 0
		}
	}
	#Calculate Energy
	$total = 0
	foreach ($planet in $planets) {
		$pot = 0
		$kin = 0
		foreach ($i in 0..2) {
			$pot += [math]::Abs($planet.Pos[$i])
			$kin += [math]::Abs($planet.Vel[$i])
		}
		$total += $pot * $kin
	}
	$total

}
Unit-Test  ${function:Solution} @{ Path="$PSScriptRoot/testcases/test1.txt"; Steps=100 } 1940
$measuredTime = measure-command { $result = Solution @{ Path="$PSScriptRoot\input.txt"; Steps=1000 } }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

