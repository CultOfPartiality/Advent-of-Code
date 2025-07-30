. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
# $Path = "$PSScriptRoot/input.txt"

#function Solution {
#    param ($Path)




# Parse the data, checking for the the min and max y, and the min x
# We'll use the min X for offsetting into the map
$data = get-content $Path | % { , ($_ -split ", ") }

$minX = 500 #The water well
$maxX = 500 #The water well
$minY = [int32]::MaxValue
$maxY = [int32]::MinValue

$clays = [System.Collections.ArrayList]@()
$EMPTY = 0
$FALLING = 1
$WATER = 2
$CLAY = 99

foreach ($row in $data) {
    $xs, $ys = $row -split ", " | sort | % { $_.TrimStart("xy=") } | % { , ($_ -split "\.\." | % { [int]$_ }) }
    if ($xs.Count -eq 1) { $xs = $xs, $xs }
    if ($ys.Count -eq 1) { $ys = $ys, $ys }

    foreach ($x in $xs[0]..$xs[1]) {
        foreach ($y in $ys[0]..$ys[1]) {
            $minX = [Math]::Min($x, $minX)
            $maxX = [Math]::Max($x, $maxX)
            $minY = [Math]::Min($y, $minY)
            $maxY = [Math]::Max($y, $maxY)
            [void]$clays.Add(@($y, $x))
        }
    }
}

# Offset all clay results, with a gap on the left and right
$width = $maxX - $minX + 1 + 2
$height = $maxY - $minY + 1 + 2

$map = New-Object int[][] $height, $width
foreach ($claySpace in $clays) {
    $map[$claySpace[0] - $minY][$claySpace[1] - $minX + 1] = $CLAY
}

function map-to-string {
    $string = ""
    foreach ($y in 0..($height - 1)) {
        $row = ""
        foreach ($x in 0..($width - 1)) {
            $row += switch($map[$y][$x]){
                $EMPTY {"."}
                $FALLING {"|"}
                $WATER {"~"}
                Default{"#"}
            }
        }
        $string += $row+"`n"
    }
    $string
}


#TODO: Launch into some sort of djkstras?

$well = [PSCustomObject]@{
    x = 500 - $minX + 1
    y = 0
}
$map[$well.y][$well.x] = $FALLING

$searchSpace = New-Object 'System.Collections.Generic.PriorityQueue[psobject,int32]'

$searchSpace.Enqueue($well,$well.y)

while($searchSpace.Count){
    $ptr = $searchSpace.Dequeue()
    $nextPtr = $ptr.psobject.Copy()

    #Check below
    switch ($map[$ptr.y+1][$ptr.x]) {
        $EMPTY { 
            $nextPtr.y += 1
            $map[$nextPtr.y][$nextPtr.x] = $FALLING
            $searchSpace.Enqueue($nextPtr,$nextPtr.y)
        }
        $CLAY { 
            #Try to spread
        }
        Default {}
    }
}
map-to-string


exit
map-to-string | Out-File  "$PSScriptRoot\DebugMap.txt"

#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

