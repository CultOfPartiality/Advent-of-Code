. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#function Solution {
#    param ($Path)

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

$data = get-content $Path

function hash-code {
	param($lastcode)
	($lastcode * 252533) % 33554393
}

<#Cantor's triangle

   | 1   2   3   4   5   6   7
---+---+---+---+---+---+---+---+
 1 |  1   3   6  10  15  21  28
 2 |  2   5   9  14  20  27
 3 |  4   8  13  19  26
 4 |  7  12  18  25
 5 | 11  17  24
 6 | 16  23
 7 | 22
#>


$coord = [PSCustomObject]@{
	row   = 1
	col   = 1
	index = 1
	code = 20151125
}

#Brueforce:

# while ( ($coord.row -ne 2947) -or 
# 		($coord.col -ne 3029) ) {

# 	if ($coord.row -eq 1) {
# 		$coord.row = $coord.col+1
# 		$coord.col = 1
# 	}
# 	else {
# 		$coord.col++
# 		$coord.row--
# 	}
# 	$coord.index++
# 	$coord.code = hash-code $coord.code
# }

while($coord.row -ne 2947){
	$coord.index += $coord.row
	$coord.row++
}
while($coord.col -ne 3029){
	$coord.index += $coord.row + $coord.col
	$coord.col++
}

for ($i = 0; $i -lt $coord.index-1; $i++) {
	$coord.code = hash-code $coord.code
}

$coord.code


#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta

