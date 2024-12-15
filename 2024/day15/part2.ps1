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


	$locations = @{}
	for ($y = 0; $y -lt $height; $y++) {
		for ($x = 0; $x -lt $width; $x++) {
			$coord1 = [coords]($y, (2 * $x))
			$coord2 = [coords]($y, (2 * $x + 1))
			
			switch ($mapRaw[$y][$x]) {
				"#" {
					$locations[$coord1.Hash()] = 9
					$locations[$coord2.Hash()] = 9
				}
				"." {}
				"@" { $bot = $coord1 }
				"O" {
					$locations[$coord1.Hash()] = 1
					$locations[$coord2.Hash()] = 2
				}
			}
		}
	}

	function print-map {
		for ($y = 0; $y -lt $height; $y++) {
			$row = ""
			for ($x = 0; $x -lt ($width * 2); $x++) {
				if ([coords]($y, $x) -eq $bot) { $row += "@" }
				else {
					$row += switch ($locations["$y,$x"]) {
						$null { "." }
						1 { "[" }
						2 { "]" }
						9 { "#" }
					}
				}
			}
			write-host $row
		}
	}

	function motion-valid($loc, $delta) {
		switch ($locations[(($loc + $delta).Hash())]) {
			$null { return $true }
			9 { return $false }
			1 {
				return ( motion-valid ($loc + $delta) $delta ) -and ( motion-valid (($loc + $delta) + (0, 1)) $delta )
			}
			2 {
				return ( motion-valid ($loc + $delta) $delta ) -and ( motion-valid (($loc + $delta) + (0, -1)) $delta )
			}
			default { return $false }
		}
	}

	function move-blocks ($loc, $delta) {
		switch ($locations[($loc.Hash())]) {
			#remove the block part so we don't get caught in a loop
			#move the block in front
			#move the "attached" block
			#move this block
			1 {
				$locations.Remove(($loc.Hash()))
				move-blocks ($loc + $delta) $delta
				move-blocks ($loc + (0, 1)) $delta
				$locations[(($loc + $delta).Hash())] = 1
			}
			2 {
				$locations.Remove(($loc.Hash()))
				move-blocks ($loc + $delta) $delta
				move-blocks ($loc + (0, -1)) $delta
				$locations[(($loc + $delta).Hash())] = 2
			}
		}
	}	

	$deltas = @{ ([char]">") = (0, 1); ([char]"<") = (0, -1); ([char]"^") = (-1, 0); ([char]"v") = (1, 0) }
	
	foreach ($dir in $moves) {	
		$delta = $deltas[$dir]
		$locInFront = $bot + $delta

		switch ($locations[$locInFront.Hash()]) {
			$null {	$bot = $locInFront }
			{ $dir -in "<", ">" -and $_ -in 1, 2 } {
				while ($locations[$locInFront.Hash()] -in 1, 2) {
					$locInFront += $delta
				}
				
				if ($null -eq $locations[$locInFront.Hash()]) {
					while ($locInFront -ne $bot) {
						$locations[$locInFront.Hash()] = $locations[($locInFront - $delta).Hash()]
						$locInFront -= $delta
					}
					$locations.Remove(($bot + $delta).Hash())
					
					$bot = $bot + $delta
				}
			}
			{ $dir -in "^", "v" -and $_ -in 1, 2 } {
				if (motion-valid $bot $delta) {
					move-blocks $locInFront $delta
					$bot = $bot + $delta
				}
			}
		}
	}

	$score = 0
	$locations.GetEnumerator() | % {
		if ($_.value -eq 1) {
			$cos = [int[]]($_.key -split ",")
			$score += 100 * $cos[0] + $cos[1]
		}
	}
	$score
}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 9021
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

