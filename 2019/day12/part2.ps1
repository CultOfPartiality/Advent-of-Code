. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test2.txt"

# function Solution {
# param ($arguments)
# $Path = $arguments.Path

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
		$planet.TotalVel = [math]::abs($planet.Vel[0]) + [math]::abs($planet.Vel[1]) + [math]::abs($planet.Vel[2])
	}
}

$steps = 0
$previousPositionsHashes = 0..3 | % { @{} }
$cycles = @(0) * 4
$finalcycles = @(0) * 4
$prevcycles = @(@(), @(), @(), @())
$cyclesValid = @(0) * 4

# Load initial locations
foreach ($index in 0..3) {
	$planet = $planets[$index]
	$hash = ($planet.Pos -join ",") + "_" + ($planet.Vel -join ",")
	$previousPositionsHashes[$index][$hash] = 0
}

do {
	$steps++
	Simulate-Universe
	$print = $false
	foreach ($index in 0..3) {
		$planet = $planets[$index]
		$hash = ($planet.Pos -join ",") + "_" + ($planet.Vel -join ",")
		if ($previousPositionsHashes[$index].ContainsKey($hash)) {
			$previousSteps = $previousPositionsHashes[$index][$hash]
			$cycle = $steps - $previousSteps
			# write-host "Step $steps, planet $index was last seen here in step $previousSteps, a period of $cycle"
			if ($cycles[$index] -ne $cycle) {
				$cyclesValid[$index] = 0
				if ($cycles[$index] -ne 0) {
					write-host "New cycle period for planet $index; was $($cycles[$index]), now $cycle" -ForegroundColor Yellow
					$prevcycles[$index] += $cycle
				}
			}
			else {
				write-host "Same cycle period twice in a row for planet $index"
				$cyclesValid[$index]++
				if($cyclesValid[$index] -ge 2){
					$finalcycles[$index] = $cycle
				}
			}
			$cycles[$index] = $cycle
			$print = $true	
		}
		$previousPositionsHashes[$index][$hash] = $steps
	}
	if ($print) {
		write-host (" - Step $($steps): " + ($cycles -join ",") + "   -   Valid: " + ($cyclesValid.ForEach({ [int]$_ }) -join ","))
		$z
	}
}while (($finalcycles -eq 0).Count)

lcm_array $finalcycles

# Debug previous cycle calcs
# $prevcycles | %{ "- " + ($_ -join ",") }

# }
# Unit-Test  ${function:Solution} @{ Path="$PSScriptRoot/testcases/test1.txt"; Steps=100 } 2772
# Unit-Test  ${function:Solution} @{ Path="$PSScriptRoot/testcases/test2.txt"; Steps=100 } 4686774924
# $measuredTime = measure-command { $result = Solution @{ Path="$PSScriptRoot\input.txt"; Steps=1000 } }
# Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

