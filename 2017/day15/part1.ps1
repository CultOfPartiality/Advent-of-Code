. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

# Faaark so slow. 114s to run... Python3 is 11s, for essentially the same approach.
function Solution {
    param ($Path)


    $data = get-content $Path
    $genA = [int64]($data[0] -split " ")[4]
    $genB = [int64]($data[1] -split " ")[4]

    $matches = 0
    for ($i = 0; $i -lt 40000000; $i++) {
        $genA = (16807 * $genA) % 2147483647
        $genB = (48271 * $genB) % 2147483647

        $matches += (($genA -band 0xFFFF) -eq ($genB -band 0xFFFF)) ? 1 : 0
    }
    $matches


}
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 588
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

