#Read file
$textInput = (Get-Content "$PSScriptRoot/input.txt")
$part1 = $textInput | foreach-object {
	$id = (Select-String 'Game (\d*)' -InputObject $_).Matches.Groups[1].Value;
	$negativeRedResults = (Select-String '(1[3-9]|[2-9][0-9]|[1-9][0-9]{2,}) red' -InputObject $_).Matches.Success;
	$negativeGreenResults = (Select-String '(1[4-9]|[2-9][0-9]|[1-9][0-9]{2,}) green' -InputObject $_).Matches.Success;
	$negativeBlueResults = (Select-String '(1[5-9]|[2-9][0-9]|[1-9][0-9]{2,}) blue' -InputObject $_).Matches.Success;

	if($negativeRedResults -or $negativeGreenResults -or $negativeBlueResults){
		0
	}
	else {
		[int]$id
	}
} | Measure-Object -Sum
"Part 1 - Total: $($part1.Sum)"

$part2 = $textInput | foreach-object {
	
	$largestRedResults = ((Select-String '(\d*) red' -InputObject $_ -AllMatches).Matches | %{$_.Groups[1].value} | measure -Maximum).Maximum;
	$largestGreenResults = ((Select-String '(\d*) green' -InputObject $_ -AllMatches).Matches | %{$_.Groups[1].value} | measure -Maximum).Maximum;
	$largestBlueResults = ((Select-String '(\d*) blue' -InputObject $_ -AllMatches).Matches | %{$_.Groups[1].value} | measure -Maximum).Maximum;

	#output game power
	$largestRedResults * $largestGreenResults * $largestBlueResults

	
} | Measure-Object -Sum
"Part 2 - Total: $($part2.Sum)"