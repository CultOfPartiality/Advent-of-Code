. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
	param ($Path)

	#The following line is for development
	# $Path = "$PSScriptRoot/testcases/test1.txt"

	$data = get-content $Path | % { , @( [regex]::Match($_,"(\d+) +(\d+) +(\d+)").Groups[1..3].Value | % { [int]$_ } | sort ) }

	$validTriangles = 0
	$data | % {
		if ( ($_[0] + $_[1]) -gt $_[2] ) {
			$validTriangles++
		}
	}
	$validTriangles
    
}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 1
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 1: $result" -ForegroundColor Magenta