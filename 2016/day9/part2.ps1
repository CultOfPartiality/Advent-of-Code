. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/part2test2.txt"


function Solution {
	param ($Path)

	#Pass in a substring with a marker and it's compressed characters
	#If those characters contain another marker, find it and recurse
	#Else, then multiply the repeat count by the number of characters and return the count
	#When counting, count the chars and groups 
	function Expand-Marker {
		param ($marker)

		#We'll keep doing isolated markers, adding recursivly to the total including the characters in between
		$NestedTotal = 0
		$leftoverseq = $marker.seq
		while ($leftoverseq -match "\(\w+\)") {
			$match = $leftoverseq | Select-String "\((\d+)x(\d+)\)" | select -ExpandProperty Matches
			$charCount = [int]$match.Groups[1].Value
			$repeatCount = [int]$match.Groups[2].Value
			$charsBeforeMatch = $match.Index
			$seq = $leftoverseq.Substring($match.Index + $match.Length, $charCount)
			
			$leftoverCharsIndex = $match.Index + $match.Length + $charCount
			$leftoverseq = $leftoverCharsIndex -lt $leftoverseq.Length ? $leftoverseq.Substring($leftoverCharsIndex) : ""

			$nestedMarker = [PSCustomObject]@{
				charCount = $charCount
				repeatCount = $repeatCount
				seq = $seq
			}
			$NestedTotal += ( $charsBeforeMatch + (Expand-Marker $nestedMarker) )
		}
		
		return $marker.repeatCount * ($NestedTotal + $leftoverseq.Length)
	}


	$rawdata = get-content $Path
	$decompressedLength = 0
	$debug = 0
	#Decompress left to right, keep track of the current "pointer" index
	#Write-Host "`nStarting Data:`n`t$rawdata" -ForegroundColor Yellow
	while ($true) {
		$match = $rawdata | Select-String "\((\d+)x(\d+)\)" | select -ExpandProperty Matches
		if (-not $match) { break }
		$charCount = [int]$match.Groups[1].Value
		$repeatCount = [int]$match.Groups[2].Value
		$seq = $rawdata.Substring($match.Index + $match.Length, $charCount)
		$marker = [PSCustomObject]@{
			charCount = $charCount
			repeatCount = $repeatCount
			seq = $seq
		}
		#add length of leading characters and then the expanded marker
		$decompressedLength += $match.Index + (Expand-Marker $marker)
		#strip the marker and nested data from the raw data and repeat
		$rawdata = $rawdata.Substring($match.index + $match.Length + $charCount)
		# Write-Host "`t($decompressedLength) + $rawdata" -ForegroundColor Yellow
		$debug++
		if ($debug % 1000 -eq 0) {
			write-host "$decompressedLength decompressed, $($rawdata.Length) chars still to go"
		}
	}
	#add any leftover charaters
	$decompressedLength += $rawdata.Length
	$decompressedLength
    
}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 9
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/part2test2.txt" 21
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/part2test3.txt" 241920
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/part2test4.txt" 445
$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta #10774309173
