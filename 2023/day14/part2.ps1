. "$PSScriptRoot\..\..\Unit-Test.ps1"

function Shift-Stones {
	param ([string]$Path)

	$map = Get-Content $Path | % { , @([char[]]$_) }
	
	Write-Host
	Write-Host ($map | % { $_ -join "" } | Join-String -Separator "`n") -ForegroundColor DarkGray

	$prevMapSerial = ""
	$sumsSeen = @()
	$iteration = 0
	$duplicatesInARow = 0
	while ($true){  #($map | % { $_ } | Join-String) -ne $prevMapSerial) {
		$prevMapSerial = $map | % { $_ } | Join-String
		#move stones up
		for ($row = 1; $row -lt $map.Count; $row++) {
			for ($col = 0; $col -lt $map[0].Length; $col++) {
				if ($map[$row][$col] -ne "O") { continue }
		
				$curRow = $row
				while ($curRow -ne 0) {
					if ($map[$curRow - 1][$col] -eq ".") {
						$map[$curRow][$col] = "."
						$curRow--
						$map[$curRow][$col] = "O"
					}
					else {
						break
					}
				}
			}
		}

		#move stones left
		for ($col = 1; $col -lt $map[0].Length; $col++) {
			for ($row = 0; $row -lt $map.Count; $row++) {
				if ($map[$row][$col] -ne "O") { continue }
		
				$curCol = $col
				while ($curCol -ne 0) {
					if ($map[$row][$curCol - 1] -eq ".") {
						$map[$row][$curCol] = "."
						$curCol--
						$map[$row][$curCol] = "O"
					}
					else {
						break
					}
				}
			}
		}

		#move stones down
		for ($row = $map.Count - 2; $row -ge 0; $row--) {
			for ($col = 0; $col -lt $map[0].Length; $col++) {
				if ($map[$row][$col] -ne "O") { continue }
		
				$curRow = $row
				while ($curRow -ne ($map.Count - 1)) {
					if ($map[$curRow + 1][$col] -eq ".") {
						$map[$curRow][$col] = "."
						$curRow++
						$map[$curRow][$col] = "O"
					}
					else {
						break
					}
				}
			}
		}

		#move stones right
		for ($col = $map[0].Length - 2; $col -ge 0; $col--) {
			for ($row = 0; $row -lt $map.Count; $row++) {
				if ($map[$row][$col] -ne "O") { continue }
		
				$curCol = $col
				while ($curCol -ne ($map[0].Length - 1)) {
					if ($map[$row][$curCol + 1] -eq ".") {
						$map[$row][$curCol] = "."
						$curCol++
						$map[$row][$curCol] = "O"
					}
					else {
						break
					}
				}
			}
		}
		$iteration++
		#write-host
		#write-Host ($map | % { $_ -join "" } | Join-String -Separator "`n") -ForegroundColor Blue

		$sum = 0
		for ($i = 0; $i -lt $map.Count; $i++) {
			$stoneCount = $map[$i] | group | ? name -eq "O" | select -ExpandProperty Count
			$weight = $map.Count - $i
			$sum += $stoneCount * $weight
		}
		if(-not $sumsSeen.Contains($sum)){
			$duplicatesInARow=0
		}
		else{
			write-host "Duplicate Sum Seen vvvvvv" -ForegroundColor Green
			$duplicatesInARow++
		}
		$sumsSeen+=$sum

		write-host "$($iteration): $($sumsSeen.Count) different weights seen, latest: $($sumsSeen[-1])"
		
		if($duplicatesInARow -gt 10){
			break	
		}
	}

	#work out period of repetition
	$prevIteration = $sumsSeen.count - $sumsSeen[($sumsSeen.count-2)..0].IndexOf($sumsSeen[-1]) - 1
	$period = $iteration - $prevIteration
	#calculate how many repeats to get to 1,000,000,000
	$howMany = 1000000000 - (([math]::floor((1000000000-$iteration)/$period)) * $period + $iteration)

	$answer = $sumsSeen[$iteration-$period+$howMany -1]

	$answer
	
}


Unit-Test  ${function:Shift-Stones} "$PSScriptRoot\testcases\test.txt" 64

$result = Shift-Stones "$PSScriptRoot\input.txt"
Write-Host "Part 2: $result" -ForegroundColor Magenta