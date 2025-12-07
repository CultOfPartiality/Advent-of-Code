. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$data = get-content $Path | % { , ($_.ToCharArray()| %{
		switch($_){
			([char]"^") {-1}
			([char]".") {0}
			([char]"S") {1}
		}
	}) }

	$start = $data[0].IndexOf(1)
	$data[0][$start] = 1

	$beamsAboveIndexes = @($start)

	for ($level = 1; $level -lt $data.Count; $level++) {
		$currentBeamIndexes = @()
		
		foreach ($beamAbove in $beamsAboveIndexes) {
			if ($data[$level][$beamAbove] -ne -1) {
				$data[$level][$beamAbove] += $data[$level-1][$beamAbove]
				$currentBeamIndexes += $beamAbove
			}
			else{
				$data[$level][$beamAbove - 1] += $data[$level-1][$beamAbove]
				$data[$level][$beamAbove + 1] += $data[$level-1][$beamAbove]
				$currentBeamIndexes += @( ($beamAbove-1), ($beamAbove+1) )
			}
		}
		$beamsAboveIndexes = $currentBeamIndexes | Select-Object -Unique
	}
	$data[-1] | sum-array
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 40
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

