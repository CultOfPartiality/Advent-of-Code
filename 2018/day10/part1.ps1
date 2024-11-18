. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/input.txt"

#function Solution {
#    param ($Path)

class Point {
    $coords
    $velocity

    Point($posString, $velString) {
        $this.coords = $posString -split "," | % { [int]$_ }
        $this.velocity = $velString -split "," | % { [int]$_ }
    }

    [void]Sim($iterations) {
        0..1 | % { $this.coords[$_] += $iterations * $this.velocity[$_] }
    }

    [void]UnSim() {
        0..1 | % { $this.coords[$_] -= $this.velocity[$_] }
    }
}

function print-points($points){
    $xStats = $points | %{$_.coords[0]} | measure -Maximum -Minimum
    $xCount = $xStats.Maximum-$xStats.Minimum +1
    $yStats = $points | %{$_.coords[1]} | measure -Maximum -Minimum
    $yCount = $yStats.Maximum-$yStats.Minimum +1

    $orderedPoints = $points | sort {$_.coords[1]} 

    $area = new-object "bool[,]" $xCount,$yCount
    foreach($point in $points){
        $area[$point.coords] = $true
    }

    for ($y = $yStats.Minimum; $y -le $yStats.Maximum; $y++) {
        $row = ""
        for ($x = $xStats.Minimum; $x -le $xStats.Maximum; $x++) {
            $row += $area[$x,$y] ? "#" : "."
        }
        write-host $row
    }

}

$points = get-content $Path | % {
    new-object Point(($_.TrimStart("position=<").TrimEnd(">") -split "> velocity=<"))
}

$ySpreadPrev = [int32]::MaxValue
$xSpreadPrev = [int32]::MaxValue
$time = 0

foreach ($point in $points) {
    $point.Sim(6000)
}

do {
    foreach ($point in $points) {
        $point.Sim(1)
    }
    $xStats = $points | %{$_.coords[0]} | measure -Maximum -Minimum
    $yStats = $points | %{$_.coords[1]} | measure -Maximum -Minimum
    $time++
    $ySpread = ($yStats.Maximum-$yStats.Minimum)
    $xSpread = ($xStats.Maximum-$xStats.Minimum)
    $deltaYSpread = [math]::abs( $ySpread - $ySpreadPrev)
    $deltaXSpread = [math]::abs( $xSpread - $xSpreadPrev)
    $shrinking = $ySpread -lt $ySpreadPrev -and $xSpread -lt $xSpreadPrev
    $ySpreadPrev = $ySpread
    $xSpreadPrev = $xSpread
    if($time%100-eq 0 -or -not $shrinking){
        write-host "Time $time, ySpread: $ySpread, ΔySpread: $deltaYSpread, xSpread: $xSpread, ΔxSpread = $deltaXSpread"
    }
    # print-points($points)
    # $z=$z
}while ($shrinking)

foreach ($point in $points) {
    $point.UnSim()
}
print-points($points)



#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

