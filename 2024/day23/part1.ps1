. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)


	$connections = get-content $Path | % { , ($_ -split "-") }
	$tConnections = $connections | ? { $_[0][0] -eq "t" -or $_[1][0] -eq "t" }

	$networks = @()

	foreach ($startPair in $tConnections) {
		$leftCons = $connections | ? { $startPair[1] -notin $_ } | ? { $_ -contains $startPair[0] }
		$rightCons = $connections | ? { $startPair[0] -notin $_ } | ? { $_ -contains $startPair[1] }
		foreach ($left in $leftCons) {
			$other = $left | ? { $_ -ne $startPair[0] }
			$rightCons | ? { $_ -contains $other } | % {
				$i++
				$networks += , ($startPair + $left + $_ | select -Unique | sort)
			}
		}
	}

	($networks | % { $_ -join "," } | select -Unique).count
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 7
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
if($result -in (2351)){write-host "Wrong answer!" -ForegroundColor Red}

