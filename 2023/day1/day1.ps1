#Read file, get all single digits from string, join first and last, convert to int, sum all results
$textInput = (Get-Content "$PSScriptRoot/input.txt")
$part1 = $textInput | foreach-object {
	$matchset = (Select-String '\d' -InputObject $_ -AllMatches).Matches;
	[int]($matchset[0].value + $matchset[-1].value)
} | Measure-Object -Sum
"Part 1 - Total: $($part1.Sum)"


#Part 2 - numbers as names count too
function name-toInt {
	param (	[string]$inString )

	switch ($inString) {
		'one' {'1'; break}
		'two' {'2'; break}
		'three' {'3'; break}
		'four' {'4'; break}
		'five' {'5'; break}
		'six' {'6'; break}
		'seven' {'7'; break}
		'eight' {'8'; break}
		'nine' {'9'; break}
		Default {$inString }
	}
}
$part2 = $textInput | foreach-object {
	$matchset = (Select-String '\d|one|two|three|four|five|six|seven|eight|nine' -InputObject $_ -AllMatches).Matches;
	[int](  [string](name-toInt($matchset[0].value)) + [string](name-toInt($matchset[-1].value))  )
} | Measure-Object -Sum
"Part 2 - Total: $($part2.Sum)"
