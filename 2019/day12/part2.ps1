. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($arguments)
	$Path = $arguments.Path

	# Parse initial planet position data
	$planets = get-content $Path | % {
		$pos = $_ -replace "[<>]", "" -split ", " | % { [int]($_ -replace "[xyz=]", "") }
		[PSCustomObject]@{
			Pos      = $pos
			Vel      = 0, 0, 0
			dv       = 0, 0, 0
			TotalVel = 0
		}
	}

	$possiblePairs = Get-AllPairs(0..3)
	function Simulate-Universe() {
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

	function Copy-Universe {
		$copy = [PSCustomObject]@{
			Steps   = $steps
			planets = @()
		}
		foreach ($index in 0..3) {
			$planet = $planets[$index]
			$copy.planets += [PSCustomObject]@{
				Pos = $planet.Pos.Clone()
				Vel = $planet.Vel.Clone()
			}
		}
		$copy
	}

	$steps = 0
	$previousPositionsHashes = 0..3 | % { @{} }

	# Load initial locations
	foreach ($index in 0..3) {
		$planet = $planets[$index]
		$hash = ($planet.Pos -join ",") + "_" + ($planet.Vel -join ",")
		$previousPositionsHashes[$index][$hash] = 0
	}
	$InitialUniverse = Copy-Universe
	$Cycles = @(0, 0, 0)

	while (0 -in $Cycles) {
		$steps++
		Simulate-Universe

		foreach ($axis in 0..2) {
			if (	$Cycles[$axis] -eq 0 -and
				$planets[0].Pos[$axis] -eq $InitialUniverse.planets[0].Pos[$axis] -and 
				$planets[1].Pos[$axis] -eq $InitialUniverse.planets[1].Pos[$axis] -and 
				$planets[2].Pos[$axis] -eq $InitialUniverse.planets[2].Pos[$axis] -and 
				$planets[3].Pos[$axis] -eq $InitialUniverse.planets[3].Pos[$axis] -and 
				$planets[0].Vel[$axis] -eq $InitialUniverse.planets[0].Vel[$axis] -and 
				$planets[1].Vel[$axis] -eq $InitialUniverse.planets[1].Vel[$axis] -and 
				$planets[2].Vel[$axis] -eq $InitialUniverse.planets[2].Vel[$axis] -and 
				$planets[3].Vel[$axis] -eq $InitialUniverse.planets[3].Vel[$axis]
			) {
				write-host "Axis $("XYZ".Substring($axis,1)) cycles at step $steps"
				$Cycles[$axis] = $steps
			}
		}
	}

	lcm_array $Cycles

}
Unit-Test  ${function:Solution} @{ Path = "$PSScriptRoot/testcases/test1.txt"; Steps = 100 } 2772
Unit-Test  ${function:Solution} @{ Path = "$PSScriptRoot/testcases/test2.txt"; Steps = 100 } 4686774924
$measuredTime = measure-command { $result = Solution @{ Path = "$PSScriptRoot\input.txt"; Steps = 1000 } }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

