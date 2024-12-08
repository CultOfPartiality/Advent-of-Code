. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

function Solution {
	param ($Path)

	# Work out the dimensions of the map, then parse all antennas. Then pair up all antennas of the same frequency, and
	# calculate the antinodes by adding/substracting the vector difference betweeen the two. If that antinode is inside
	# the map, add it to the hash so we can keep track of the unique locations.

	# This problem made good use of "useful stuff": the Coords class and the Get-AllPairs function. It also highlighted
	# a classic PowerShell blunder: make sure your checks for equality are case sensitive when using strings!

	$data = get-content $Path
	$width = $data[0].Length
	$height = $data.Count

	$antennas = @()
	for ($y = 0; $y -lt $width; $y++) {
		for ($x = 0; $x -lt $height; $x++) {
			if ($data[$y][$x] -ne ".") {
				$antennas += [PSCustomObject]@{
					Freq  = $data[$y][$x]
					Coord = [Coords]($y, $x)
				}
			}
		}
	}

	$antiNodeLocations = @{}
	foreach ( $Freq in (Select -InputObject $antennas.Freq -unique) ) {
		foreach ( $pair in Get-AllPairs ($antennas.Where({ $_.Freq -ceq $Freq })) ) {
			$diff = $pair[0].Coord - $pair[1].Coord
			($pair[0].Coord + $diff), ($pair[1].Coord - $diff) | % {
				if ($_.Contained($height, $width)) {
					$antiNodeLocations[$_.Hash()]++
				}
			}
		}
	}

	# Output the number of unique antinodes
	$antiNodeLocations.Count
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 14
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

