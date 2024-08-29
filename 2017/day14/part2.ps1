. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

# Knot-Hashing function from day 10
. "$PSScriptRoot\..\day10\knot_hash.ps1"

#The following line is for development
$in = "flqrgnkx"

function Solution {
	param ($in)
	Write-host "Generating hashes"
	$hashes = 0..127 | % { Knot-Hash ($in + "-" + $_) }
	$binaryData = $hashes | % {
		, [int[]]($_.ToCharArray() | % {
				$int = [System.Convert]::ToInt32($_, 16)
				[system.convert]::ToString($int, 2).PadLeft(4, "0").ToCharArray() | % { [int][string]$_ }
			})
	}
	
	# Start with a random used square, and search outward using a queue
	# Once used, modify the data to be blank
	# Once all attached squares found, start with another set square
	$groups = 0
	$startRow = 0
	$totalUnchecked = ($binaryData | % { $_ | ? { $_ -eq 1 } } | group | ? { $_.name -eq 1 } | select -ExpandProperty Count)
	while ($totalUnchecked -gt 0) {
		# Find new starting point
		:findStartPoint for ($row = $startRow; $row -lt $binaryData.Count; $row++) {
			if (($binaryData[$row] -eq 1).Count -eq 0) { $startRow++; continue }
			for ($col = 0; $col -lt $binaryData[0].Count; $col++) {
				if ($binaryData[$row][$col]) {
					$startPoint = [PSCustomObject]@{
						row = $row
						col = $col
					}
					break findStartPoint
				}
			}
		}

		# Search and remove, using a queue
		$searchSpace = New-Object System.Collections.Queue
		$searchSpace.Enqueue($startPoint)
		while ($searchSpace.Count) {
			$point = $searchSpace.Dequeue()
			if($binaryData[$point.row][$point.col] -eq 0){continue}
			
			$binaryData[$point.row][$point.col] = 0
			$totalUnchecked--
			
			if (
				($point.row -lt ($binaryData.Count-1)) -and 
				($binaryData[$point.row + 1][$point.col] -eq 1)
			){$searchSpace.Enqueue([PSCustomObject]@{row = $point.row + 1; col = $point.col })}
			
			if (
				($point.row -gt 0) -and
				($binaryData[$point.row - 1][$point.col] -eq 1)
			) { $searchSpace.Enqueue([PSCustomObject]@{row = $point.row - 1; col = $point.col }) }
			
			if (
				($point.col -lt ($binaryData[0].Count-1)) -and
				($binaryData[$point.row][$point.col + 1] -eq 1)
			) { $searchSpace.Enqueue([PSCustomObject]@{row = $point.row; col = $point.col + 1 }) }

			if (
				($point.col -gt 0) -and
				($binaryData[$point.row][$point.col - 1] -eq 1)
			){ $searchSpace.Enqueue([PSCustomObject]@{row = $point.row; col = $point.col - 1 }) }
		}
		$groups++
		if ($groups % 10 -eq 0) {
			write-host "$groups groups found so far..."
		}
	}

	$groups
}

Unit-Test  ${function:Solution} "flqrgnkx" 1242
$measuredTime = measure-command { $result = Solution "hfdlxzhv" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

