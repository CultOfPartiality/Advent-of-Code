. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

#function Solution {
#    param ($Path)

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
    }
}

# Start at "FUEL", and work out from there
$NeedToMake = @{"FUEL" = 1 }
$nextToMake = @{}
$totalOre = 0

<#
TODO - charaterise the recipies in terms of the max distance to Fuel, then walk them 
starting closest to fuel out, adding up how much of each is needed along the way.
#>
do{
    $NeedToMake.GetEnumerator() | %{ #TODO need to walk in reverse?
        write-host "To make $($_.value) x $($_.key), we need to make:"
        foreach($ingredient in $recipies[$_.Key].Ingredients){
            $recipieRuns = [math]::Ceiling($_.Value/$ingredient.Amount)
            write-host "`t$recipieRuns lot of $($ingredient.amount)x$($ingredient.Material)"
            if($ingredient.Material -eq "ORE"){
                $totalOre += $ingredient.amount * $recipieRuns
                continue
            }
            $nextToMake[$ingredient.Material] += $ingredient.amount * $recipieRuns
        }
    }
    $NeedToMake = $nextToMake.Clone()
    $nextToMake = @{}

}while($NeedToMake.Values.Count)
    
#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

