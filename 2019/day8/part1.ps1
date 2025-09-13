. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

function Solution {
	param ($Path)

	# 25 pixels wide by 6 pixels tall
	$layers = (get-content $Path).ToCharArray().ForEach({ ([int]$_) - 48 }) | Split-Array -GroupSize (25 * 6)

	$layerInfo = $layers | % { , ($_ | Group-Object) }

	$minLayer = $layerInfo | Sort-Object -Property { $_[0].count } | select -First 1

	$minLayer[1].count * $minLayer[2].count

}
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

