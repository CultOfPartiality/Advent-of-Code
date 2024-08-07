. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)


	$data = get-content $Path | % { , @( [regex]::Match($_,"(\d+) +(\d+) +(\d+)").Groups[1..3].Value | % { [int]$_ } ) }
	#Grab columns as triangles instead
	$newData = for ($i = 0; $i -lt $data.Count; $i+=3) {
		, (($data[$i][0],$data[$i+1][0],$data[$i+2][0]) | sort)
		, (($data[$i][1],$data[$i+1][1],$data[$i+2][1]) | sort) 
		, (($data[$i][2],$data[$i+1][2],$data[$i+2][2]) | sort)
	}


	$validTriangles = 0
	$newData | % {
		if ( ($_[0] + $_[1]) -gt $_[2] ) {
			$validTriangles++
		}
	}
	$validTriangles
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 2
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 2: $result" -ForegroundColor Magenta #620 is too low