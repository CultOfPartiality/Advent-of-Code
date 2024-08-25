. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$in = "1,2,3"

function Solution {
	param ($in)

	$lengths = ($in).ToCharArray() | % { [int]$_ }
	$lengths += (17, 31, 73, 47, 23)

	$list = 0..255
	$skipSize = 0
	$rotationAmount = 0

	foreach ($round in 1..64) {
		foreach ($length in $lengths) {
			# Split list into two sublists
			$index = $length
			if ($length -ne 0) {
				$subList = [System.Collections.ArrayList]$list[0..($index - 1)]
				$remainder = $list[$index..($list.Count - 1)]
				# Reverse the first one
				$subList.Reverse()
				# Rotate the list left by the prescribed amount (record so we can "unrotate" later)
				if ($length -lt $list.Count) {
					$list = ([array]$subList + $remainder)
				}
				else {
					$list = [array]$subList
				}
			}
			$rotateIndex = ($length + $skipSize) % $list.Count
			if ($rotateIndex) {
				$rotationAmount += $rotateIndex
				$list = $list[$rotateIndex..($list.Count - 1)] + $list[0..($rotateIndex - 1)]
			}
			$skipSize++
		}
	}
	$rotateBackIndex = ($list.Count - ($rotationAmount % $list.Count)) % $list.Count
	if($rotateBackIndex){
		$list = $list[$rotateBackIndex..($list.Count - 1)] + $list[0..($rotateBackIndex - 1)]
	}

	# Convert sparse hash to dense hash
	$denseHash = for ($blockIndex = 0; $blockIndex -lt $list.Count; $blockIndex += 16) {
		$result = $list[$blockIndex]
		$sublist = $list[($blockIndex + 1)..($blockIndex + 15)]
		$subList | % { $result = $result -bxor $_ }
		$result
	}
	[convert]::ToHexString($denseHash).ToLower()


}
Unit-Test  ${function:Solution} "" "a2582a3a0e66e6e86e3812dcb672a272"
Unit-Test  ${function:Solution} "AoC 2017" "33efeb34ea91902bb2f59c9920caa6cd"
Unit-Test  ${function:Solution} "1,2,4" "63960835bcdc130f0b66d7ff4f6a5a8e"
Unit-Test  ${function:Solution} "1,2,3" "3efbe78a8d82f29979031a4aa0b16a9d"
Write-Host "        84973a9101625cffff6a54344bdf0910 is the wrong answer BTW..." -ForegroundColor DarkGray
$measuredTime = measure-command { $result = Solution (get-content "$PSScriptRoot\input.txt") }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta