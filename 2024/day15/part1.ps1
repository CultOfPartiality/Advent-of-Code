. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

function Solution {
	param ($Path)

	$rawData = get-content $Path
	$mapRaw = $rawData.where({ $_ -eq "" }, "Until")
	$height = $mapRaw.Count
	$width = $mapRaw[0].Length
	$moves = ($rawData.where({ $_ -eq "" }, "SkipUntil") -join "").toCharArray()


	function index($coord) { $coord.row * $width + $coord.col }
	
	$map = for ($y = 0; $y -lt $height; $y++) {
		for ($x = 0; $x -lt $width; $x++) {
			switch ($mapRaw[$y][$x]) {
				"#" { 9 }
				"." { 0 }
				"@" {
					$bot = [coords]($y, $x)
					0
				}
				"O" { 1 }
			}
		}


		function print-map {
			for ($y = 0; $y -lt $height; $y++) {
				$row = ""
				for ($x = 0; $x -lt $width; $x++) {
					$row += switch ($map[($y * $width + $x)]) {
						0 { "." }
						1 { "0" }
						9 { "#" }
					}
				}
				write-host $row
			}
		}

		$deltas = @{ ([char]">") = (0, 1); ([char]"<") = (0, -1); ([char]"^") = (-1, 0); ([char]"v") = (1, 0) }

		foreach ($dir in $moves) {
			$delta = $deltas[$dir]
			$locInFront = $bot + $delta
			switch ($map[(index($locInFront))]) {
				0 {	$bot = $locInFront }
				1 {
					while ($map[(index($locInFront))] -eq 1) {
						$locInFront += $delta
					}
					if ($map[(index($locInFront))] -eq 0) {
						$map[(index($bot + $delta))] = 0
						$map[(index($locInFront))] = 1
						$bot = $bot + $delta
					}
				}
			}
		}

		$score = 0
		for ($y = 0; $y -lt $height; $y++) {
			for ($x = 0; $x -lt $width; $x++) {
				if ($map[($y * $width + $x)] -eq 1) {
					$score += 100 * $y + $x
				}
			}
		}
		$score
	}

	Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 2028
	Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 10092
	$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
	Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

