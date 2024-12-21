. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

#The following line is for development
$arguments = @{Path = "$PSScriptRoot/testcases/test1.txt"; thresh = 2; dist = 2 }

function Solution {
	param ($arguments)

	$data = get-content $arguments.Path
	$width = $data[0].length
	$height = $data.count

	#Flood fill from the exit, to get the distance from any point to the exit, as well as the 
	#normal race time
	# Generate the map with the number of corrupted bytes
	$map = New-Object "int[,]" $height, $width
	for ($y = 0; $y -lt $height; $y++) {
		for ($x = 0; $x -lt $width; $x++) {
			$coord = [coords]($y, $x)
			switch ($data[$y][$x]) {
				'#' {
					$map[$y, $x] = -1
				}
				'S' { $start = $coord; }
				'E' { $end = $coord }
				'.' {}
			}
		}
	}
	$track = @($start)

	# Walk the path from the start, counting the number of steps to get there
	$nextStep = $start
	$steps = 0
	while ($nextStep -ne $end) {
		$cell = $nextStep
		foreach ($validNeighbour in $cell.ValidOrthNeighbours($height, $width)) {
			$val = $map[$validNeighbour.Array()]
			if ($val -eq -1) { continue } #Don't go into wall
			if ($validNeighbour -eq $start) { continue } #Don't go back to the 'start'
			if ($val -eq 0) {
				$steps++
				$map[$validNeighbour.Array()] = $steps
				$track += $validNeighbour
				$nextStep = $validNeighbour
				break
			}
		}
	}

	# For part 2, this section stil dominates runtime
	$cheats = 0
	$dist = $arguments.dist
	$thresh = $arguments.thresh
	foreach ($step in $track) {
		$startSteps = $map[$step.Array()]
		foreach($y in  ([math]::Max(($step.row - $dist), 0))..([math]::Min(($step.row + $dist), $height-1))) {
			foreach($x in ([math]::Max(($step.col - $dist), 0))..([math]::Min(($step.col + $dist), $width-1))) {
				$endSteps = $map[$y, $x]
                
				#Ignore walls
				if ($endSteps -eq -1) { continue }
                
				#Ignore going backwards, or not far enough
				$nonCheatDist = $endSteps - $startSteps
				if ($nonCheatDist -lt $thresh) { continue }
                
				#Make sure the manhattan distance is valid
				#  - Creating an object is comparivly expensive when just doing the maths is possible, so
				#    the following actually doubles execution time:
				# 		$cheatDist = $step.Distance(([coords]($y, $x))) 
				
				$cheatDist = [math]::abs($step.col-$x) + [math]::abs($step.row-$y)
				if ($cheatDist -gt $dist) { continue }
                
				#Need to save at least the threshold
				if ( ($nonCheatDist - $cheatDist) -ge $thresh) {
					$cheats++
				}
			}
		}
	}
	$cheats
}

# Part 1
Unit-Test  ${function:Solution} @{Path = "$PSScriptRoot/testcases/test1.txt"; thresh = 2; dist = 2 } 44
Unit-Test  ${function:Solution} @{Path = "$PSScriptRoot/input.txt"; thresh = 100; dist = 2 } 1459 #Result for part 1

# $measuredTime = measure-command { $result = Solution @{Path = "$PSScriptRoot\input.txt"; thresh = 100; dist = 2 } }
# Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta


# Part 2
Unit-Test  ${function:Solution} @{Path = "$PSScriptRoot/testcases/test1.txt"; thresh = 50; dist = 20 } 285
Unit-Test  ${function:Solution} @{Path = "$PSScriptRoot/input.txt"; thresh = 100; dist = 20 } 1016066 #Result for part 2

# $measuredTime = measure-command { $result = Solution @{Path = "$PSScriptRoot\input.txt"; thresh = 100; dist = 20 } }
# Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
