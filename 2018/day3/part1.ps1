. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)


	$claims = get-content $Path | % {
		$parts = $_ -split " "
		$coords = $parts[2].replace(":", "") -split ","
		$size = $parts[3] -split "x"
		[PSCustomObject]@{
			id     = [int]$parts[0].replace('#', "")
			x0     = [int]$coords[0] 
			y0     = [int]$coords[1]
			x1     = ([int]$coords[0] + [int]$size[0] - 1)
			y1     = ([int]$coords[1] + [int]$size[1] - 1)
			width  = [int]$size[0]
			height = [int]$size[1]
		}
	}

	$area = @{}

	foreach ($claim in $claims) {
		for ($x = $claim.x0; $x -le $claim.x1; $x++) {
			for ($y = $claim.y0; $y -le $claim.y1; $y++) {
				$area["$x,$y"]++
			}
		}
	}

	($area.values | ? { $_ -gt 1 }).count
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 4
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

