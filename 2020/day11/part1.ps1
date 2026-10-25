. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$data = get-content $Path

	$width = $data[0].Length
	$height = $data.count
	$map = [int[, ]]::new($height,$width)

	enum SeatState {
		Floor = 0
		Empty = 1
		Occupied = 2
	}

	for ($y = 0; $y -lt $height; $y++) {
		for ($x = 0; $x -lt $width; $x++) {
			$map[$y, $x] = $data[$y][$x] -eq "L" ? [SeatState]::Empty : [SeatState]::Floor
		}
	}

	function Get-8Coords {
		param ($y, $x, $height, $width)

		$coords = (($y - 1), ($x - 1)), (($y - 1), $x), (($y - 1), ($x + 1)),
		( $y, ($x - 1)), ( $y, ($x + 1)),
		(($y + 1), ($x - 1)), (($y + 1), $x), (($y + 1), ($x + 1))
		foreach($coord in $coords){
			if($coord[0] -ge 0 -and $coord[0] -lt $height -and
			$coord[1] -ge 0 -and $coord[1] -lt $width
			){
				,$coord
			}
		}
	}

	$activity = $true
	$round = 0
	while ($activity) {
		$round++
		write-host "Round $round"
		$activity = $false
		$newMap = [int[, ]]::new($height,$width)

		for ($y = 0; $y -lt $height; $y++) {
			for ($x = 0; $x -lt $width; $x++) {
				if($map[$y, $x] -eq [SeatState]::Floor){continue}
				$surroudingSeated = 0
				foreach($coord in (Get-8Coords $y $x $height $width)){
					if($map[$coord] -eq [seatstate]::Occupied){$surroudingSeated++}
				}
				if ($map[$y, $x] -eq [SeatState]::Empty -and $surroudingSeated -eq 0) {
					$newMap[$y, $x] = [SeatState]::Occupied
					$activity = $true
				}
				elseif ($map[$y, $x] -eq [SeatState]::Occupied -and $surroudingSeated -ge 4) {
					$newMap[$y, $x] = [SeatState]::Empty
					$activity = $true
				}
				else {
					$newMap[$y, $x] = $map[$y, $x]
				}
			}
		}
		$map = $newMap.Clone()

		# foreach ($y in 0..($height - 1)) {
		# 	$line = ""
		# 	foreach ($x in 0..($width - 1)) {
		# 		$line += switch ([seatstate]$map[$y, $x]) {
		# 			Floor { "." }
		# 			Empty { "L" }
		# 			Occupied { "#" }
		# 			default { throw "Unknown seat state: $($map[$y, $x])" }
		# 		}
		# 	}
		# 	write-host $line
		# }
	}

	($map | ? { $_ -eq [SeatState]::Occupied }).count
   
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 37
Unit-Test  ${function:Solution} "$PSScriptRoot/input.txt" 2126
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

