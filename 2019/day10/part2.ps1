. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test5.txt"

function Solution {
	param ($Path)

	write-host "`nWorking out directions..."
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
	function PolarAngle([Coords]$dir) {
		if ($dir.col -eq 0 -and $dir.row -ge 0) { return [Math]::PI / 2 }
		elseif ($dir.col -eq 0) { return [Math]::PI * 3 / 2 }
		$angle = [math]::Atan([math]::abs($dir.row) / [math]::abs($dir.col))

		if ($dir.col -ge 0 -and $dir.row -ge 0) { return $angle }
		if ($dir.col -ge 0 -and $dir.row -lt 0) { return [math]::pi * 2 - $angle }
		if ($dir.col -lt 0 -and $dir.row -ge 0) { return [math]::pi - $angle }
		if ($dir.col -lt 0 -and $dir.row -lt 0) { return [math]::pi + $angle }	
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
	#Using polar, sort directions to start pointing up, then going clockwise
	$directions = $directions.Values | Sort-Object -Property {
		$angle = PolarAngle($_)
		( $angle + 1 / 2 * [math]::pi + 0.000001) % (2 * [math]::PI)
	}

	# Walk each direction, looking until we hit an asteroid or out of bounds, to find the best asteroid for the station
	write-host "Working out best asteroid..."
	$bestAsteroid = [PSCustomObject]@{ Coords = $null; AsteroidsSeen = 0 }
	$delta = [coords]::New(0, 0) # Cloning is very slow
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
				# if (!$delta.Contained($height, $width)) { break }
				if ( $delta.row -ge $height -or
					 $delta.row -lt 0 -or
					 $delta.col -ge $width -or
					 $delta.col -lt 0) { break }

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

	write-host "Vaporising..."
	# Loop over the directions in order, vaporising asteroids until we hit asteroid 200
	$dirIndex = 0
	$asteroidsVaporised = 0
	$delta = [coords]::New(0, 0) # Cloning is very slow
	while ($asteroidsVaporised -ne 200) {
		$direction = $directions[$dirIndex] 
		$dirIndex = ($dirIndex + 1) % $directions.count
		#Reset delta
		$delta.row = $bestAsteroid.Coords.row
		$delta.col = $bestAsteroid.Coords.col
		while ($true) {
			$delta.row += $direction.row
			$delta.col += $direction.col
			if (!$delta.Contained($height, $width)) { break } # Our biggest hotspot #TODO remove directions once we know they're all used up?
			if ($asteroids.ContainsKey($delta.Hash($width))) {
				# write-host "Asteroid #$($asteroidsVaporised+1) varporised @ $($asteroids[$delta.Hash($width)].hash())"
				$asteroidsVaporised++
				break
			}
		}
	}
	$twohundredth = $asteroids[$delta.Hash($width)]
	$twohundredth.col * 100 + $twohundredth.row


}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test5.txt" 802
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" } #1321
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
