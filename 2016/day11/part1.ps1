. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

#function Solution {
#    param ($Path)


$setup = get-content $Path

<#Rules
 - Chips can only be on the same floor as RTGs if their matching RTG is on the same floor
 - Elevator can carry two objects
 - Elevator must have at least one object to move between floors
 - Get all objects to top floor
#>

function calc-score{
    param($floors)
    return  3 * ($floors[1].Generators.Count + $floors[1].Microchips.Count) + 
            2 * ($floors[2].Generators.Count + $floors[2].Microchips.Count) + 
            1 * ($floors[3].Generators.Count + $floors[3].Microchips.Count)
}
$floors = @{}
1..4 | % {
    $floors[$_] = [PSCustomObject]@{
        Elevator = $false
        Floor = $_
        Generators = @()
        Microchips = @()
    }
}
$floors[1].Elevator = $true

foreach($floorIndex in 1..4){
    $floorDetails = $setup[$floorIndex-1]
    $microchips = ($floorDetails | Select-String -AllMatches "(\w*)-compatible microchip").Matches
    foreach($microchip in $microchips){
        $floors[$floorIndex].Microchips += $microchip.Groups[1].Value
    }
    $generators = ($floorDetails | Select-String -AllMatches "(\w*) generator").Matches
    foreach($generator in $generators){
        $floors[$floorIndex].Generators += $generator.Groups[1].Value
    }
}
$floors.score = calc-score -floors $floors

$floors



#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

