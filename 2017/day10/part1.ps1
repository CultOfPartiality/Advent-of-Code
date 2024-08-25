. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($in)

	$Path = $in

	$lengths = [int[]]((get-content $Path) -split ",")

	$list = 0..255
	$skipSize = 0
	$rotationAmount = 0

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
	$rotateBackIndex = $list.Count - ($rotationAmount % $list.Count)
	$list = $list[$rotateBackIndex..($list.Count - 1)] + $list[0..($rotateBackIndex - 1)]

	$list[0] * $list[1]

}
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 12
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
#3660 is too low

