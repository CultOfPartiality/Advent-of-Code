. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/testcases/test2.txt"
$Path = "$PSScriptRoot/testcases/test3.txt"
$Path = "$PSScriptRoot/testcases/test4.txt"
$Path = "$PSScriptRoot/testcases/test5.txt"


function Solution {
	param ($Path)

	$rawdata = get-content $Path
	$done = $false
	$index = 0
	#Decompress left to right, keep track of the current "pointer" index
	#Write-Host "Starting Data:`n`t$rawdata" -ForegroundColor Yellow
	while ($true) {
		$marker = $rawdata.Substring($index) | Select-String "\((\d+)x(\d+)\)" | select -ExpandProperty Matches
		if (-not $marker) { break }
		$charCount = [int]$marker.Groups[1].Value
		$repeatCount = [int]$marker.Groups[2].Value
		$seq = $rawdata.Substring($index + $marker.Index + $marker.Length, $charCount)
		$decompressed = ($seq * $repeatCount)
		$rawdata = $rawdata.Substring(0, $index + $marker.Index) + $decompressed + $rawdata.Substring($index + $marker.Index + $marker.Length + $charCount)
		$index += $decompressed.Length
		#Write-Host "`t$rawdata" -ForegroundColor Yellow
		write-host $rawdata.Substring(0,200)
		$z=$z
	}
	$rawdata.Length
    
}

# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 7
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 9
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" 11
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test4.txt" 6
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test5.txt" 18
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 1: $result" -ForegroundColor Magenta #110346
