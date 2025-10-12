. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
   param ($Path)

    # Parse the data into recipies
    $recipies = @{}
    get-content $Path | %{
        $rawIngredients,$rawResult = $_ -split " => "
        $ingredients = $rawIngredients -split ", " | %{
            [int]$num,$material = $_ -split " "
            [PSCustomObject]@{
                Material = $material
                Amount = $num
            }
        }
        [int]$num,$material = $rawResult -split " "
        $recipies[$material] = [PSCustomObject]@{
            Material = $material
            Amount = $num
            Ingredients = $ingredients
            DistFromFuel = 0
        }
    }


    # Charaterise the recipies in terms of the max distance to Fuel, then walk them 
    # starting closest to fuel out, adding up how much of each is needed along the way.
    function Walk-Recipies {
        param(
            $recipie,
            $possibleDist
        )
        if($recipie.Ingredients.Material -ne "ORE"){
            foreach($Ingredient in $recipie.Ingredients.Where({$_.Material -ne "ORE"})){
                $subRecipie = $recipies[$Ingredient.Material]
                Walk-Recipies $subRecipie ($possibleDist+1)
            }
        }
        $recipie.DistFromFuel = [Math]::Max($recipie.DistFromFuel,$possibleDist)
    }
    Walk-Recipies $recipies["FUEL"] 0
    
    # Start at "FUEL", and work out from there
    $NeedToMake = @{}
    $NeedToMake["FUEL"] = [PSCustomObject]@{
        Material = "FUEL"
        Recipie = $recipies["FUEL"]
        AmountRequired = 1
    }
    
    $totalOre = 0
    while($NeedToMake.Count){
        $Make = $NeedToMake.Values | Sort-Object {$_.Recipie.DistFromFuel} | select -First 1
        $NeedToMake.Remove($Make.Material)
        
        $ActualBatchesToMake = [Math]::Ceiling($Make.AmountRequired/$Make.Recipie.Amount)
        $ActualAmountToMake = [Math]::Ceiling($Make.AmountRequired/$Make.Recipie.Amount)*$Make.Recipie.Amount

        write-host "To make $($Make.AmountRequired) lots of $($Make.Material), we'll have to make $ActualAmountToMake lots, which is $ActualBatchesToMake batches of $($Make.Recipie.Amount)x$($Make.Material):"
        # $Make.Recipie
        foreach($ingredient in $Make.Recipie.Ingredients){
            $ingredientRecipie = $Recipies[$ingredient.Material]
            $required = $ActualBatchesToMake*$ingredient.Amount
            Write-Host "`t$required x $($ingredient.Material)"
            if($ingredient.Material -eq "ORE"){
                # $required = [MATH]::Ceiling($ActualAmountToMake/$Make.Recipie.Amount) * $ingredient.Amount
                # Write-Host ("`t`t($($ActualBatchesToMake) batches is ($($Ingredient.Material)x$required)")
                # $totalOre += [MATH]::Ceiling($required/$ingredientRecipie.Amount) * $ingredient.Amount
                $totalOre += $required
                continue
            }
            # Write-Host "`t`t(Each recipie for $($ingredient.Material) makes $($ingredientRecipie.Amount))"
            # Write-Host "`t`t(We need to run the recipie $recipieRuns times, making $($recipieRuns* $ingredientRecipie.Amount) lots of $($ingredient.Material))"
            if($NeedToMake.ContainsKey($ingredient.Material)){
                $NeedToMake[$ingredient.Material].AmountRequired += $required
            }
            else{
                $NeedToMake[$ingredient.Material] = [PSCustomObject]@{
                    Material = $ingredient.Material
                    Recipie = $recipies[$ingredient.Material]
                    AmountRequired = $required
                }
            }
        }    
    }

    $totalOre
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 31
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 165
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" 13312
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test4.txt" 180697
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test5.txt" 2210736
$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

