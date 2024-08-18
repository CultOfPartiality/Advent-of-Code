. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

# function Solution {
# 	param ($Path)
# 	$number = [int] (get-content $Path)

###Testing	
for ($i = 2; $i -le 300; $i++) {
	$elves = New-Object "System.Collections.ArrayList"
		
	1..$i | % { $index = $elves.Add($_) }

	function steal {
		param($elves)
	
		#Removed elf is lower index of count/2 (-1 to convert to index)
		$elves.RemoveAt([math]::Floor($elves.Count / 2))
	
		#rotate elves
		$lastElf = $elves[0]
		$elves.RemoveAt(0)
		$null = $elves.Add($lastElf)
		$z = $z
	}

	while ($elves.count -gt 1) {steal $elves}

	#Work out power of 3 that's bigger than the number
	$pow = 1
	while($pow -lt $i){$pow *=3}
	$biggerPow3 = $pow
	$smallerPow3 = $pow/3
	$halfwayPow3 = ($biggerPow3 - $smallerPow3)/2 + $smallerPow3
	#If we're bigger than a power of 3, then add to 1 the amount over we are
	$guess = 1 + ($i-$smallerPow3-1)
	#If we're at or over halfway to the next power of three, as another 1 for each from that midpoint
	if( $i -ge $halfwayPow3 ){
		$guess += ($i-$halfwayPow3)
	}

	if($elves[0] -ne $guess){
		write-host "$i elves - $elves wins (Guess: $guess)" -ForegroundColor Red
	}
}
# }

#Actual solution
$realInput = 3004953
#Work out power of 3 that's bigger than the number
$pow = 1
while($pow -lt $realInput){$pow *=3}
$biggerPow3 = $pow
$smallerPow3 = $pow/3
$halfwayPow3 = ($biggerPow3 - $smallerPow3)/2 + $smallerPow3
#If we're bigger than a power of 3, then add to 1 the amount over we are
$guess = 1 + ($realInput-$smallerPow3-1)
#If we're at or over halfway to the next power of three, as another 1 for each from that midpoint
if( $realInput -ge $halfwayPow3 ){
	$guess += ($realInput-$halfwayPow3)
}
write-host "$realInput elves - $guess wins" -ForegroundColor Magenta


# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 3
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

