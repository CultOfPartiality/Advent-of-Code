. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test2.txt"

# function Solution {
#     param ($Path)

$null, $busesRaw = get-content $Path
$buses = $busesRaw -split "," | % { $_ -eq "x" ? 0 : [int]$_ }
$offsets = 0..($buses.Count-1) | ?{$buses[$_] -ne 0}

<#

t   = a*offset[0]
t+1 = b*offset[1]
t+2 = c*offset[2]
t+3 = d*offset[3]

a*offset[0] - t = 0
b*offset[1] - t = 1
c*offset[2] - t = 2
d*offset[3] - t = 3

o[0] 0    0    0    -1    a     1
0    o[1] 0    0    -1    b     2
0    0    o[2] 0    -1 *  c  =  3
0    0    0    o[3] -1    d     4
                          t
#>

#LCM of all buses seems to be an upper bound. Not sure if useful though

#Naive solution; this feels like more of a matrix elimination thing? Or some sort of LCM? Works, but obviously too slow
function Naive {
    param($buses,$offsets)
    $t = $buses[0]
    $valid=$false
    while(! $valid){
        write-host "Checking time = $t"
        $valid=$true
        foreach($offset in $offsets){
            if( ([math]::DivRem( ($t+$offset),$buses[$offset])).Item2 -ne 0){
                $t += $buses[0]
                $valid=$false
                break
            }
        }
    }
    $t
}
#Naive $buses $offsets

#https://math.stackexchange.com/questions/2218763/how-to-find-lcm-of-two-numbers-when-one-starts-with-an-offset
#https://cp-algorithms.com/algebra/extended-euclid-algorithm.html

Function Min-TimeStep{
    param(
        $Pa,$Pb,$Ob
    )
    # $Pa = 17
    # $Pb = 13
    $Pc = lcm $Pa $Pb
    $Oa = 0 #Since we'll always reference bus in position 0
    # $Ob = 0
    
    $g,$s,$t = xgcd $Pa $Pb
    
    $z = ($Oa - $Ob)/$g
    $m=$z*$s
    # $n=-$z*$t
    
    $minStep = ($m*$Pa - $Oa) % $Pc
    # $minStep = ($n*$Pb + $Ob) % $Pc
    $minStep
}


$minStep = $buses[0]
foreach($offset in $offsets){
    if($offset -eq 0){continue}
    $minStep = Min-TimeStep $minStep $buses[$offset] $offset
    write-host "Adding $($buses[$offset]) with offset $offset, new min time: $minStep"
}




# }
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 3417
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 1068781
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
