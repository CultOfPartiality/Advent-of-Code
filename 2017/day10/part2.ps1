. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

# Converted solution to function, for reuse in day 14
. "$PSScriptRoot\knot_hash.ps1"


#The following line is for development
$in = "1,2,3"

function Day10_Solution {
	param ($in)

	Knot-Hash $in

}
Unit-Test  ${function:Day10_Solution} "" "a2582a3a0e66e6e86e3812dcb672a272"
Unit-Test  ${function:Day10_Solution} "AoC 2017" "33efeb34ea91902bb2f59c9920caa6cd"
Unit-Test  ${function:Day10_Solution} "1,2,4" "63960835bcdc130f0b66d7ff4f6a5a8e"
Unit-Test  ${function:Day10_Solution} "1,2,3" "3efbe78a8d82f29979031a4aa0b16a9d"
Write-Host "        84973a9101625cffff6a54344bdf0910 is the wrong answer BTW..." -ForegroundColor DarkGray
$measuredTime = measure-command { $result = Day10_Solution (get-content "$PSScriptRoot\input.txt") }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta