. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test2.txt"

function Solution {
    param ($Path)

    $null, $busesRaw = get-content $Path
    $buses = $busesRaw -split "," | % { $_ -eq "x" ? 0 : [int]$_ }
    $offsets = 0..($buses.Count - 1) | ? { $buses[$_] -ne 0 }

    #Naive solution; this feels like more of a matrix elimination thing? Or some sort of LCM? Works, but obviously too slow
    function Naive {
        param($buses, $offsets)
        $t = $buses[0]
        $valid = $false
        while (! $valid) {
            write-host "Checking time = $t"
            $valid = $true
            foreach ($offset in $offsets) {
                if ( ([math]::DivRem( ($t + $offset), $buses[$offset])).Item2 -ne 0) {
                    $t += $buses[0]
                    $valid = $false
                    break
                }
            }
        }
        $t
    }
    #Naive $buses $offsets


    <#Chinese remainder theorum? Each bus is prime, so are therefore pairwise coprime
     https://rosettacode.org/wiki/Chinese_remainder_theorem

    (t+i) mod b = 0; b => bus[i]
    
    (t+0) % 17 = 0  |  0 % 17 = t+0   | t ≡ 17-0 % 17
    (t+2) % 13 = 0  |  0 % 13 = t+2   | t ≡ 13-2 % 13
    #>

    $N = $offsets | % { $buses[$_] } | Multiply-Array
    $sol = $offsets | % {
        # t = b[i]-i % b[i]
        $ai = $buses[$_] - $_
        $ni = $buses[$_]
        $g, $ri, $si = xgcd $ni ($N / $ni)
        ($ai * $si * $N / $ni) % $N
    } | sum-array

    while($sol -lt 0){$sol+=$N}
    $sol
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 1068781
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 3417
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" 754018
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
