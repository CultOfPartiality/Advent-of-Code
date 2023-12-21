. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

# function Solution {
# 	param ($Path)

#The following line is for development
#$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/input.txt"

$data = get-content $Path

#Parse possible ingredients
$ingredients = foreach ($line in $data) {
	$name, $null, $capacity, $null, $durability, $null, $flavour, $null, $texture, $null, $calories = $line -split ': |, | '
	[PSCustomObject]@{
		name       = $name
		capacity   = [int]$capacity
		durability = [int]$durability
		flavour    = [int]$flavour
		texture    = [int]$texture
		calories   = [int]$calories
		count      = 0
	}
}

$currentScore = [PSCustomObject]@{
	capacity   = 0
	durability = 0
	flavour    = 0
	texture    = 0
	calories   = 0
}
1..100 | % {
	#check which increase is the best, or the least negative
	#if any scores are negative, return the sum of all negative results to get it to pick the best of the worst
	$possibleScoreIncreases = foreach ($ingredient in $ingredients) {
		$increases = @(
			($ingredient.capacity + $currentScore.capacity),
			($ingredient.durability + $currentScore.durability),
			($ingredient.flavour + $currentScore.flavour),
			($ingredient.texture + $currentScore.texture)
		)
		if ($increases.Where{ $_ -lt 0 }) {
			$increases.Where{ $_ -lt 0 } | measure -Sum | select -ExpandProperty Sum
		}
		else {
			[math]::max(0, $increases[0]) * 
			[math]::max(0, $increases[1]) * 
			[math]::max(0, $increases[2]) * 
			[math]::max(0, $increases[3])
		}
	}
	$maxScoreIncrease = $possibleScoreIncreases | measure -Maximum | select -ExpandProperty Maximum
	$bestIngredient = $ingredients[$possibleScoreIncreases.IndexOf([int]$maxScoreIncrease)]
	$bestIngredient.count++
	$currentScore.capacity += $bestIngredient.capacity
	$currentScore.durability += $bestIngredient.durability
	$currentScore.flavour += $bestIngredient.flavour
	$currentScore.texture += $bestIngredient.texture
	$currentScore.calories += $bestIngredient.calories
}

$score = ($ingredients.ForEach({ $_.Count * $_.capacity })   | measure -sum).Sum *
		 ($ingredients.ForEach({ $_.Count * $_.durability }) | measure -sum).Sum *
		 ($ingredients.ForEach({ $_.Count * $_.flavour })    | measure -sum).Sum *
		 ($ingredients.ForEach({ $_.Count * $_.texture })    | measure -sum).Sum

$calories = ($ingredients.ForEach({ $_.Count * $_.calories })| measure -sum).Sum

Write-Host "Best score is $score with $calories calories" -ForegroundColor Yellow
$3,$8 = $ingredients.where({$_.calories -eq 3},'split')

($3 | %{$_.count} | measure -sum).sum
($8 | %{$_.count} | measure -sum).sum


#while calories -gt 500


#}

# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 62842880
# $result = Solution "$PSScriptRoot\input.txt"
# Write-Host "Part 2: $result" -ForegroundColor Magenta

