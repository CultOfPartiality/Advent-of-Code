$map,$clue = "?#.?..?.##.###? 2,1,2,3" -split " "
$clues = $clue -split ","
$spacesCount = $map.Length - ($clues|measure -Sum).Sum
$minSpaces = $spacesCount - ($clues.count -1)
$moveableSpaces = $spacesCount - $minSpaces
$spaces = 0..($clues.count+1) | %{1}
$spaces[0] = 0
$spaces[-1] = $moveableSpaces

#plan is to interate over space options, generate all possible options that are valid with given map

Write-Host "Clue: $clue"



0..($map.Length-1) | %{
	if($_ % 2){
		'#' * [int]$clues[($_-1)/2]
	}
	else{
		'.' * $spaces[$_/2]
	}
} | Join-String