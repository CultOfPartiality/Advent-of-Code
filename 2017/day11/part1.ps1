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
    $e = 0

    # NE + NW = N = 1 step North
    # -NE + NW = SW+NW = 2 steps "Westward"
    # -NE + -NW = SW+SE = 1 step south
    # NE + -NW = NE+SE = 2 steps "Eastward"
    switch ( @([math]::Sign($ne),[math]::Sign($nw)) ) {
        (1,1) {
            $n += [System.Math]::Min($ne,$nw)
            $e += $ne-$nw
        }
        Default {
            if($ne -ne 0)
        }
    }
    $SideComponent_of_ne_nw = [math]::abs($ne - $nw)
    $NorthComponent_of_ne_nw = [math]::min($ne, $nw)
    $total = [math]::Abs($n + $NorthComponent_of_ne_nw + $SideComponent_of_ne_nw)
    $total
}


Unit-Test  ${function:Solution} "ne,ne,ne" 3
Unit-Test  ${function:Solution} "ne,ne,sw,sw" 0
Unit-Test  ${function:Solution} "ne,ne,s,s" 2
Unit-Test  ${function:Solution} "se,sw,se,sw,sw" 3
$measuredTime = measure-command { $result = Solution (Get-Content "$PSScriptRoot\input.txt") }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

