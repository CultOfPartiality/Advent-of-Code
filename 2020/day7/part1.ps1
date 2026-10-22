. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$BagTypes = @{}

	get-content $Path | % {
		$split = $_ -split "s contain "
		[object[]]$held = $split[1] -split ", " | % {
			$_.TrimEnd(".") -replace "\d", "" -replace "bags", "bag"
		} | % { $_.Trim() }
	
		$BagTypes[$split[0]] = [PSCustomObject]@{
			holds       = $held
			containedIn = @()
		}
	}

	foreach ($key in $BagTypes.keys) {
		$bag = $BagTypes[$key]
		foreach ($innerBag in $bag.holds) {
			if ($innerBag -eq "no other bag") { continue }
			elseif ($BagTypes.ContainsKey($innerBag)) {
				$BagTypes[$innerBag].containedIn += $key
			}
		}
	}

	$finalBags = [System.Collections.Generic.HashSet[string]]::new()
	$bagsToCheck = [System.Collections.Stack]::new()
	$bagsToCheck.Push('shiny gold bag')

	while ($bagsToCheck.Count) {
		$bagToCheck = $bagsToCheck.pop()
		$BagTypes[$bagToCheck].containedIn | % {
			$bagsToCheck.push($_)
			$finalBags.add($_) | out-null
		}
	}

	$finalBags.Count

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 4
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
