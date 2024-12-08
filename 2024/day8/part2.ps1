. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	# Part 2 is exactly the same as part 1, except each pair of antennas is added as an antinode,
	# and the antinodes repeat in each direction until they're outside the map

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
			$antiNodeLocations[$pair[0].Coord.Hash()]++
			$antiNodeLocations[$pair[1].Coord.Hash()]++
			
			$possibleLoc = $pair[0].Coord
			while($true){
				$possibleLoc += $diff
				if(-not $possibleLoc.Contained($height, $width)){
					break
				}
				$antiNodeLocations[$possibleLoc.Hash()]++
			}
			$possibleLoc = $pair[1].Coord
			while($true){
				$possibleLoc -= $diff
				if(-not $possibleLoc.Contained($height, $width)){
					break
				}
				$antiNodeLocations[$possibleLoc.Hash()]++
			}
		}
	}

	# Output the number of unique antinodes
	$antiNodeLocations.Count
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 34
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

