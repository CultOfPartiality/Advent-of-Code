$exampleText = Get-Content "$PSScriptRoot/example.txt" #Answer should be 13 and 30
$inputText = Get-Content "$PSScriptRoot/input.txt"

#Part 1

#Get the two sets of numbers
$part1 = $inputText | ForEach-Object{
	$winningNums,$givenNums = ($_ | Select-String ':(.*)\|(.*)').Matches.Groups[1,2].value | %{ $_| Select-String '\d+' -AllMatches }
	$winningNums = $winningNums.Matches.Value
	$givenNums = $givenNums.Matches.Value
	$numsInBoth = Compare-Object $winningNums $givenNums -ExcludeDifferent|select -ExpandProperty inputobject
	
	#output score
	($numsInBoth.count -gt 0) ? [math]::Pow(2,$numsInBoth.Count-1) : 0
	
} | Measure-Object -sum |select -ExpandProperty Sum
write-host "Part 1: $part1"

#Part 2
$initialCards = $inputText | ForEach-Object{
	$winningNums,$givenNums = ($_ | Select-String ':(.*)\|(.*)').Matches.Groups[1,2].value | %{ $_| Select-String '\d+' -AllMatches }
	$winningNums = $winningNums.Matches.Value
	$givenNums = $givenNums.Matches.Value
	$numsInBoth = Compare-Object $winningNums $givenNums -ExcludeDifferent|select -ExpandProperty inputobject
	
	#output information
	@{
		numberOfCards=1;
		matchingNums=$numsInBoth.Count;
	}
}

#loop over cards from top to botton
#add 'numberOfCards' to each of 'matchingNums' cards below 
for ($i = 0; $i -lt $initialCards.Count; $i++) {
	$curCard = $initialCards[$i]
	for ($j = 1; $j -le $curCard.matchingNums; $j++) {
		$initialCards[$i+$j].numberOfCards += $curCard.numberOfCards
	}
}

$part2 = $initialCards.numberOfCards | measure -sum |select -ExpandProperty sum

write-host "Part 2: $part2 cards in total"