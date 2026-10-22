. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$BagTypes = @{}

	get-content $Path | % {
		$split = $_ -split "s contain "
		$BagTypes[$split[0]] = [PSCustomObject]@{
			OneContainsTotal = -1
			holds            = @{}
		}
		[object[]]$held = $split[1] -split ", " | % {
			$cleaned = $_.TrimEnd(".") -replace "bags", "bag"
			$number = [int][regex]::match($cleaned, "\d*").Value
			$bag = $cleaned.TrimStart("$number ")
			if ($bag -eq "no other bag") { return }
			$BagTypes[$split[0]].holds[$bag] = $number
		}
	}

	function Get-TotalBags {
		param ($bag)
	
		if ($Bag.OneContainsTotal -ne -1) { return $Bag.OneContainsTotal }

		$bag.OneContainsTotal = 0

		foreach ($key in $bag.holds.keys) {
			$bag.OneContainsTotal += $bag.holds[$key] * ((Get-TotalBags $BagTypes[$key]) + 1)
		}

		return $bag.OneContainsTotal
	}

	Get-TotalBags $BagTypes['shiny gold bag']


}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 32
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 126
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
