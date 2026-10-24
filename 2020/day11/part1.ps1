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

	for ($y = 0; $y -lt $height; $y++) {
		for ($x = 0; $x -lt $width; $x++) {
			$map[$y, $x] = $data[$y][$x] -eq "L" ? 0 : -1
		}
	}

	function Get-8Coords {
		param ($y, $x)
		
		(($y - 1), ($x - 1)), (($y - 1), $x), (($y - 1), ($x + 1)),
		( $y, ($x - 1)), ( $y, ($x + 1)),
		(($y + 1), ($x - 1)), (($y + 1), $x), (($y + 1), ($x + 1)) | ? {
			$_[0] -ge 0 -and $_[0] -lt $height -and
			$_[1] -ge 0 -and $_[1] -lt $width
		}
	}

	$activity = $true
	$round = 0
	while ($activity) {
		$round++
		write-host "Round $round"
		$activity = $false
		$newMap = $map.clone()

		for ($y = 0; $y -lt $height; $y++) {
			for ($x = 0; $x -lt $width; $x++) {
				$surroudingSeated = (Get-8Coords $y $x | ? { $map[$_] -eq 1}).count
				if ($map[$y, $x] -eq 0 -and $surroudingSeated -eq 0) {
					$newMap[$y, $x] = 1
					$activity = $true
				}
				if ($map[$y, $x] -eq 1 -and $surroudingSeated -ge 4) {
					$newMap[$y, $x] = 0
					$activity = $true
				}
			}
		}
		$map = $newMap
	}

	($map | ? { $_ -eq 1 }).count
   
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 37
Unit-Test  ${function:Solution} "$PSScriptRoot/input.txt" 2126
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

