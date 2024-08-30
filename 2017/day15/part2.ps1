. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

# Only 39s to run, better than part 1. Python3 is 8s
function Solution {
    param ($Path)


    $data = get-content $Path
    $genA = [int64]($data[0] -split " ")[4]
    $genB = [int64]($data[1] -split " ")[4]

    $matches = 0
    for ($i = 0; $i -lt 5000000; $i++) {
        do{$genA = (16807 * $genA) % 2147483647}
        while( ($genA -band 0b11) -ne 0)
        
        do{$genB = (48271 * $genB) % 2147483647}
        while( ($genB -band 0b111) -ne 0)

        $matches += (($genA -band 0xFFFF) -eq ($genB -band 0xFFFF)) ? 1 : 0
    }
    $matches


}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 309
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

