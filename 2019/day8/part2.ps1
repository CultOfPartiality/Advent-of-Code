. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

function Solution {
	param ($Path)

	# 25 pixels wide by 6 pixels tall
	$layers = (get-content $Path).ToCharArray().ForEach({ ([int]$_) - 48 }) | Split-Array -GroupSize (25 * 6)

	foreach($row in 0..5){
		$rowData = ''
		foreach($col in 0..24){
			$pixel = 2
			$layer = 0
			while($pixel -eq 2){
				$pixel = $layers[$layer][$row*25 + $col]
				$layer++
			}
			$rowData += $pixel ? "▓" : "░"
		}
		write-host $rowData
	}

}
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

