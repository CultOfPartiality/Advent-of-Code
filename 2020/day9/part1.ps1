. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$argHash = @{
    path     = "$PSScriptRoot/testcases/test1.txt"
    preamble = 5
}
function Solution {
    param ($argHash)

    $preamble = $argHash.preamble
    [int64[]]$data = get-content $argHash.Path

    $index = $preamble
    while ($true) {
        $preceedingValues = $data[($index - $preamble)..($index - 1)]
        $value = $data[$index]
        #Ugly... maybe keeping a hash that counts the possible additions to the same value and allows us to decrement when they fall of the end?
        #Works for now, 4s though...
        $keys = [System.Collections.Generic.HashSet[int]]::new() 
        Get-AllPairs -array $preceedingValues | % { $keys.Add($_[0] + $_[1]) | out-null }

        if (!$keys.Contains($value)) {
            return $value
        }
        $index++
    }   
}
Unit-Test  ${function:Solution} @{Path = "$PSScriptRoot/testcases/test1.txt"; preamble = 5 } 127
$measuredTime = measure-command { $result = Solution @{Path = "$PSScriptRoot\input.txt"; preamble = 25 } }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

