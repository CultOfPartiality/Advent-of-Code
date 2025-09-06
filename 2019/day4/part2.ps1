. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

function Solution {
    param ($Path)

    $valid = 0
    $testVal, $limit = [int[]] ((get-content $Path) -split "-")
  
    while ($testVal -le $limit) {
        $val = ([string]$testVal).ToCharArray() | % { [int]$_ - 48 }
  
        #Check for validity
        $matchedPair = $false
        foreach ($pair in 0..4) {
            $matchedPair = $matchedPair -or (
                $val[$pair] -eq $val[$pair + 1] -and
                ($pair -eq 0 -or $val[$pair] -ne $val[$pair - 1]) -and
                ($pair -ge 4 -or $val[$pair] -ne $val[$pair + 2])
            )
            if ($val[$pair] -gt $val[$pair + 1]) {
                for ($i = $pair + 1; $i -lt 6; $i++) {
                    $val[$i] = $val[$pair]
                }
                $matchedPair = $false
                $testVal = ([int]($val -join '')) - 1
                break
            }
        }
        if ($matchedPair) { $valid++ }
        $testVal++
    }
    $valid

}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

