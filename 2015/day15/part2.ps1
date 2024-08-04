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

function recipe-score{
	param($ingredients)
	$currentScore = [PSCustomObject]@{
		capacity   = ($ingredients.ForEach({ $_.Count * $_.capacity   }) | measure -sum).Sum
		durability = ($ingredients.ForEach({ $_.Count * $_.durability }) | measure -sum).Sum 
		flavour    = ($ingredients.ForEach({ $_.Count * $_.flavour    }) | measure -sum).Sum 
		texture    = ($ingredients.ForEach({ $_.Count * $_.texture    }) | measure -sum).Sum
		calories   = ($ingredients.ForEach({ $_.Count * $_.calories   }) | measure -sum).Sum
		score 	   = 0
	}
	$currentScore.score = $currentScore.capacity * $currentScore.durability * $currentScore.flavour * $currentScore.texture
	$currentScore
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

$recipe = recipe-score $ingredients

Write-Host "Best score is $($recipe.score) with $($recipe.calories) calories" -ForegroundColor Yellow
$3,$8 = $ingredients.where({$_.calories -eq 3},'split')

($3 | %{$_.count} | measure -sum).sum
($8 | %{$_.count} | measure -sum).sum


while( $currentScore.calories -gt 500 ){
	#first remove one of each of the 8 calorie ingredients, then pick the biggest score.
	#then add each of the 3 calorie ingredients, and see which makes the score bigger
	$smallestScoreDecrease = $ingredients | ? {$_.calories -eq 8} | % {
		$ingredient = $_
		$newScore = ($currentScore.capacity - $ingredient.capacity     ) * 
					($currentScore.durability - $ingredient.durability ) * 
					($currentScore.flavour - $ingredient.flavour       ) *
					($currentScore.texture - $ingredient.texture       )
		[PSCustomObject]@{
			ingredient = $ingredient
			score = $newScore
		}
	} | sort -Property score -Descending
	
	$smallestScoreDecrease[0].ingredient.count--
	$currentScore.capacity   -= $smallestScoreDecrease[0].ingredient.capacity
	$currentScore.durability -= $smallestScoreDecrease[0].ingredient.durability
	$currentScore.flavour    -= $smallestScoreDecrease[0].ingredient.flavour
	$currentScore.texture    -= $smallestScoreDecrease[0].ingredient.texture
	$currentScore.calories   -= $smallestScoreDecrease[0].ingredient.calories

	$smallestScoreDecrease = $ingredients | ? {$_.calories -eq 3} | % {
		$ingredient = $_
		$newScore = ($currentScore.capacity   + $ingredient.capacity      ) * 
					($currentScore.durability + $ingredient.durability    ) * 
					($currentScore.flavour    + $ingredient.flavour       ) *
					($currentScore.texture    + $ingredient.texture       )
		[PSCustomObject]@{
			ingredient = $ingredient
			score = $newScore
		}
	} | sort -Property score -Descending
	
	$smallestScoreDecrease[0].ingredient.count++
	$currentScore.capacity   += $smallestScoreDecrease[0].ingredient.capacity
	$currentScore.durability += $smallestScoreDecrease[0].ingredient.durability
	$currentScore.flavour    += $smallestScoreDecrease[0].ingredient.flavour
	$currentScore.texture    += $smallestScoreDecrease[0].ingredient.texture
	$currentScore.calories   += $smallestScoreDecrease[0].ingredient.calories

}
$recipe = recipe-score $ingredients

Write-Host "Best score is $($recipe.score) with $($currentScore.calories) calories" -ForegroundColor Yellow

#Huh, no good. Lets try swapping each of the 3 and 8 calorie ingredients, if the score is bigger

$healthyIngredients = $ingredients | ? {$_.calories -eq 3}
$unhealthyIngredients = $ingredients | ? {$_.calories -eq 8}

$recipe = recipe-score $ingredients
do{
	$outerPrvScore = $recipe.score
	do {
		$prevScore = $recipe.score
		$healthyIngredients[0].count--
		$healthyIngredients[1].count++
		$recipe = recipe-score $ingredients
	} while ($recipe.score -gt $prevScore)
	$healthyIngredients[0].count++
	$healthyIngredients[1].count--
	$recipe = recipe-score $ingredients

	do {
		$prevScore = $recipe.score
		$healthyIngredients[0].count++
		$healthyIngredients[1].count--
		$recipe = recipe-score $ingredients
	} while ($recipe.score -gt $prevScore)
	$healthyIngredients[0].count--
	$healthyIngredients[1].count++
	$recipe = recipe-score $ingredients

	do {
		$prevScore = $recipe.score
		$unhealthyIngredients[0].count--
		$unhealthyIngredients[1].count++
		$recipe = recipe-score $ingredients
	} while ($recipe.score -gt $prevScore)
	$unhealthyIngredients[0].count++
	$unhealthyIngredients[1].count--
	$recipe = recipe-score $ingredients

	do {
		$prevScore = $recipe.score
		$unhealthyIngredients[0].count++
		$unhealthyIngredients[1].count--
		$recipe = recipe-score $ingredients
	} while ($recipe.score -gt $prevScore)
	$unhealthyIngredients[0].count--
	$unhealthyIngredients[1].count++
	$recipe = recipe-score $ingredients
} while($recipe.score -gt $outerPrvScore )

Write-Host "Best score is $($recipe.score) with $($currentScore.calories) calories" -ForegroundColor Yellow

# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 62842880
# $result = Solution "$PSScriptRoot\input.txt"
# Write-Host "Part 2: $result" -ForegroundColor Magenta

