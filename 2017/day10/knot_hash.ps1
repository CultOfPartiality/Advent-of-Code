function Knot-Hash {
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