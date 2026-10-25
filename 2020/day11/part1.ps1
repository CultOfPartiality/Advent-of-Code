. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$data = get-content $Path

	$width = $data[0].Length
	$height = $data.count
	$map = [psobject[, ]]::new($height,$width)

	enum SeatState {
		Floor = 0
		Empty = 1
		Occupied = 2
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

	for ($y = 0; $y -lt $height; $y++) {
		for ($x = 0; $x -lt $width; $x++) {
			$map[$y, $x] = [pscustomobject]@{
				state = ($data[$y][$x] -eq "L" ? [SeatState]::Empty : [SeatState]::Floor),[SeatState]::Floor
				neighbours = (Get-8Coords $y $x $height $width)
			}
		}
	}

	

	$activity = $true
	$round = 0
	while ($activity) {
		$currentState = $round % 2
		$nextState = ($round+1) % 2
		$round++
		write-host "Round $round"
		$activity = $false
		
		for ($y = 0; $y -lt $height; $y++) {
			for ($x = 0; $x -lt $width; $x++) {
				$seat = $map[$y, $x]
				if($seat.state[$currentState] -eq [SeatState]::Floor){continue}
				$surroudingSeated = 0
				foreach($coord in $seat.neighbours){
					if($map[$coord].state[$currentState] -eq [seatstate]::Occupied){$surroudingSeated++}
				}
				if ($seat.state[$currentState] -eq [SeatState]::Empty -and $surroudingSeated -eq 0) {
					$seat.state[$nextState] = [SeatState]::Occupied
					$activity = $true
				}
				elseif ($seat.state[$currentState] -eq [SeatState]::Occupied -and $surroudingSeated -ge 4) {
					$seat.state[$nextState] = [SeatState]::Empty
					$activity = $true
				}
				else{
					$seat.state[$nextState] = $seat.state[$currentState]
				}
			}
		}
	}

	($map | ? { $_.State[$nextState] -eq [SeatState]::Occupied }).count
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 37
Unit-Test  ${function:Solution} "$PSScriptRoot/input.txt" 2126
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

