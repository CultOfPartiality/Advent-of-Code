. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
# $Path = "$PSScriptRoot/input.txt"

function Solution {
	param ($Path)

	# Parse data
	$data = get-content $Path
	$width = $data[0].length
	$height = $data.count

	$asteroids = @{}
	for ($x = 0; $x -lt $width; $x++) {
		for ($y = 0; $y -lt $height; $y++) {
			if ($data[$y][$x] -eq "#") {
				$asteroid = [Coords]::New($y, $x)
				$asteroids[$asteroid.Hash($width)] = $asteroid
			}
		}
	}

	# Work out all possible directions from 0,0 in their simplest form to remove duplicates
	$directions = @{}
	for ($x = 0; $x -lt $width; $x++) {
		for ($y = 0; $y -lt $height; $y++) {
			if ($x -eq 0 -and $y -eq 0) { continue }
			$gcd = gcd $x $y
			$direction = [coords]::new($y / $gcd, $x / $gcd)

			# Flips need to avoid 1D directions....
			$flips = @(1, 1), @(1, -1), @(-1, 1), @(-1, -1)
			if ($direction.row -eq 0) {
				$flips = @(1, 1), @(1, -1)
			}
			if ($direction.col -eq 0) {
				$flips = @(1, 1), @(-1, 1)
			}
			foreach ($flip in $flips) {
				$modDirection = $direction * $flip
				$directions[$modDirection.Hash()] = $modDirection
			}
		}
	}
	$directions = $directions.Values

	$bestAsteroid = [PSCustomObject]@{
		Coords        = $null
		AsteroidsSeen = 0
	}
	
	# Walk each direction, looking until we hit an asteroid or out of bounds
	$delta = [coords]::New(0,0) # Cloning is very slow
	foreach ($asteroid in $asteroids.Values) {
		# write-host "Checking asteroid at $($asteroid.Hash())"
		$AsteroidsSeen = 0
		foreach ($direction in $directions) {
			$delta.row = $asteroid.row
			$delta.col = $asteroid.col
			while ($true) {
				$delta.row += $direction.row
				$delta.col += $direction.col
				# The below halves the run time, I'm assuming because we exit early?
				if ( ($delta.row -ge $height) -or
					 ($delta.row -lt 0) -or
					 ($delta.col -ge $width) -or
					 ($delta.col -lt 0) ) { break }
				
				if ($asteroids.ContainsKey($delta.Hash($width))) {
					# write-host "  Can see $($delta.Hash())"
					$AsteroidsSeen++
					break
				}
			}

			if ($AsteroidsSeen -gt $bestAsteroid.AsteroidsSeen) {
				$bestAsteroid.Coords = $asteroid
				$bestAsteroid.AsteroidsSeen = $AsteroidsSeen
			}
		}
	}
	$bestAsteroid.AsteroidsSeen

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 8
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 33
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" 35
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test4.txt" 41
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test5.txt" 210
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" } #276
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

