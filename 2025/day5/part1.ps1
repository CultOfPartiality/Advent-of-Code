. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$data = get-content $Path | ? { $_.Length -gt 0 }
	$ranges = $data | ? { $_ -match "-" } | % { , @($_ -split "-" | % { [int64]$_ }) }
	$ids = $data | ? { $_ -notmatch "-" } | % { [int64]$_ }

	$total = 0
	foreach ($id in $ids) {
		foreach ($range in $ranges) {
			if (($id -ge $range[0]) -and ($id -le $range[1])) {
				# write-host "Id $id is valid in range $($range -join "-")"
				$total++
				break
			}
		}
	}
	$total

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 3
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

