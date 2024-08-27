. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$data = "ne,ne,s,s,sw,se,n"

function Solution {
    param ($data)

    $data = $data -split "," | group

    # Start by grouping all options, and summing (10*N+9S = 1N)

    $n = ($data | ? { $_.Name -eq "n" }).Count - ($data | ? { $_.Name -eq "s" }).Count 
    $ne = ($data | ? { $_.Name -eq "ne" }).Count - ($data | ? { $_.Name -eq "sw" }).Count
    $nw = ($data | ? { $_.Name -eq "nw" }).Count - ($data | ? { $_.Name -eq "se" }).Count

    # If ne and nw are both the same direction then we can balance
    if([math]::sign($ne) -eq [math]::sign($nw)){
        $vert = $n + [math]::MinMagnitude($ne,$nw)
        $diag = $ne - $nw
        $total = [math]::abs($vert) + [math]::abs($diag)
    }
    # If n is zero, (and we know ne and nw are different signs and thus go in the same E or W direction),
    # then we can just add the magnitudes of ne and nw 
    elseif($n -eq 0) {
        $total = [math]::abs($ne) + [math]::abs($nw)
    }
    # If n is going in the same direction as the vertical component of ne and nw, then they add with no overlap
    elseif([math]::sign($ne+$nw) -eq [math]::sign($n)){
        $vert = $n + [math]::MinMagnitude($ne,$nw)
        $diag = $ne - $nw
        $total = [math]::abs($vert) + [math]::abs($diag)
    }
    # Else, the north component subtracts from that from the ne/nw
    else{
        $vertOffset = $ne+$nw
        $vert = $n
        if([math]::abs($n) -le [math]::abs($vertOffset)){
            $total = [math]::abs($ne+$nw)
        }
        else{
            $total = [math]::abs([math]::MaxMagnitude($vert,$vertOffset))
        }
    }

    # $x = ($ne-$nw)*[math]::Cos([math]::PI/6)
    # $y = $n + ($ne+$nw)*[math]::Sin([math]::PI/6)
    # $hyp = [math]::sqrt($x*$x + $y*$y)

    # $vertSteps = 

    # $diagSteps = [math]::Sqrt( $hyp*$hyp - $n*$n )
    # $total = [math]::Round([math]::ABS($n) + $diagSteps)
    $total
}


Unit-Test  ${function:Solution} "se,sw,se,sw,sw,s" 4
Unit-Test  ${function:Solution} "se,sw,se,sw,sw,n" 2
Unit-Test  ${function:Solution} "ne,ne,ne" 3
Unit-Test  ${function:Solution} "ne,ne,sw,sw" 0
Unit-Test  ${function:Solution} "ne,ne,s,s" 2
Unit-Test  ${function:Solution} "ne,ne,s,s,s" 3
Unit-Test  ${function:Solution} "ne,ne,ne,s,s" 3
Write-Host "Part 1: 231 is too low" -ForegroundColor DarkGray
$measuredTime = measure-command { $result = Solution (Get-Content "$PSScriptRoot\input.txt") }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

