. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$data = get-content $Path | % { , $_.ToCharArray() }
	$width = $data[0].Count

	$start = $data[0].IndexOf([char]'S')
	$data[0][$start] = "|"

	$splits = 0
	for ($level = 1; $level -lt $data.Count; $level++) {
		#Find all the beams above
		$beamsAboveIndexes = 0..($width - 1) | ? { $data[$level - 1][$_] -eq "|" }
		foreach ($beamAbove in $beamsAboveIndexes) {
			if ($data[$level][$beamAbove] -eq [char]".") {
				$data[$level][$beamAbove] = "|"
			}
			elseif ($data[$level][$beamAbove] -eq [char]"^") {
				$data[$level][$beamAbove - 1] = "|"
				$data[$level][$beamAbove + 1] = "|"
				$splits++
			}
		}
		# write-host "Debug, level $level"
		# $data | %{write-host ($_ -join "")}
		# write-host
	}
	$splits
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 21
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

