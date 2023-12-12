$map,$clue = "?#?#?#?#?#?#?#? 11,3,1,6" -split " "
$clues = $clue -split ","
$spacesCount = $map.Length - ($clues|measure -Sum).Sum
$minSpaces = $spaces - ($clues.count -1)
$moveableSpaces = $spaces - $minSpaces
$spaces = 0..($clues.count+1) | %{1}
$spaces[0] = 0
$spaces[-1] = $moveableSpaces

#plan is to interate over space options, generate all possible options that are valid with given map
