. "$PSScriptRoot\..\Unit-Test.ps1"




function Shift-Stones {
	param ([string]$Path)

	$map = Get-Content $Path | % { , @([char[]]$_) }

	# Write-Host ($map | % { $_ -join "" } | Join-String -Separator "`n") -ForegroundColor DarkGray

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

	# write-host
	# write-Host ($map | % { $_ -join "" } | Join-String -Separator "`n") -ForegroundColor Blue

	$sum = 0
	for ($i = 0; $i -lt $map.Count; $i++) {
		$stoneCount = $map[$i] | group | ? name -eq "O" | select -ExpandProperty Count
		$weight = $map.Count - $i
		$sum += $stoneCount * $weight
	}

	$sum
}

Unit-Test  ${function:Shift-Stones} "$PSScriptRoot\testcases\test.txt" 136
$result = Shift-Stones "$PSScriptRoot\input.txt"
Write-Host "Part 1: $result" -ForegroundColor Magenta