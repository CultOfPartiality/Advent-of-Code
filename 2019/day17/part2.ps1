. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

# Reused IntCode computer this year
. "$PSScriptRoot\..\IntCodeComputer.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

# function Solution {
#     param ($Path)
$memory = (get-content $Path) -split ',' | % { [int64]$_ }
$ASCII = [Computer]::New($memory)

while (!$ASCII.complete) {
    $ASCII.RunComputer($null)
}

# Write map
# $ASCII.outputBuffer | % { [char]$_ } | Join-String -Separator "" | write-host


# Setup the map and robot
$robot = [PSCustomObject]@{
    dir = 0 # 0-3: Up,Right,Down,Left
    x   = 0
    y   = 0
}
$RawPath = @()
$map = @(, @())
$ASCII.outputBuffer | % {
    $val = [char]$_
    if ($_ -eq 10) { $map += , @() }
    else { $map[-1] += $val }
    if ($val -in "<", ">", "v", "^") {
        $initialDir = @{"^" = 0; ">" = 1; "v" = 2; "<" = 3 }
        $robot.dir = $initialDir["$val"]
        $robot.y = $map.count - 1
        $robot.X = $map[-1].count - 1
    }
}
$width = $map[0].Count
$height = $map.Count - 2 # Couple of blank lines at the end...?

# Work out initial turn to align with scaffold.
#   Based on the problem, this will always be straight, left, or right
$turn = 0
$turn = switch ("#") {
    ($map[$robot.y][$robot.x+1]) { [math]::Sign(1 - $robot.dir) }
    ($map[$robot.y][$robot.x-1]) { [math]::Sign(($robot.dir-1) % 2) }
    ($map[$robot.y+1][$robot.x]) { [math]::Sign(2 - $robot.dir) }
    ($map[$robot.y-1][$robot.x]) { [math]::Sign(($robot.dir-2) % 2) }
}
if($turn -ne 0){
    $RawPath += $turn -eq 1 ? "R" : "L"
    $robot.dir = ($robot.dir + 4 + $turn) % 4
}

# Walk the scaffold, only turning when you have to (i.e. go straight through intersections)
$ForwardXYDelta = @{
    "^" = @(0,-1);  0 = @(0,-1);
    ">" = @(1,0);   1 = @(1,0); 
    "v" = @(0,1);   2 = @(0,1); 
    "<" = @(-1,0);  3 = @(-1,0); 
}#x,y
function Can-Walk-Forward{
    $delta = $ForwardXYDelta[$robot.dir]
    $newXY = ($robot.x+$delta[0]),($robot.y+$delta[1])
    if($newXY -lt 0){$false; return}
    if($newXY[0] -ge $width){$false; return}
    if($newXY[1] -ge $height){$false; return}
    if($map[$newXY[1]][$newXY[0]] -ne "#"){$false;return}
    $true;
}

function Turn-Direction{
    $leftTileDelta = $ForwardXYDelta[(($robot.dir+3) % 4)]
    $leftTileCoords = ($robot.x+$leftTileDelta[0]),($robot.y+$leftTileDelta[1])
    if(-1 -notin $leftTileCoords){
        $leftTile = $map[$leftTileCoords[1]][$leftTileCoords[0]]
        if($leftTile -eq "#"){3; return}
    }
    $rightTileDelta = $ForwardXYDelta[(($robot.dir+1) % 4)]
    $rightTileCoords = ($robot.x+$rightTileDelta[0]),($robot.y+$rightTileDelta[1])
    if(-1 -notin $rightTileCoords){
        $rightTile = $map[$rightTileCoords[1]][$rightTileCoords[0]]
        if($rightTile -eq "#"){1; return}
    }
    0 # No turn, we're at the end
}

do{
    # Walk forward as long as we can
    $steps = 0
    while(Can-Walk-Forward){
        $steps++
        $delta = $ForwardXYDelta[$robot.dir]
        $robot.x+=$delta[0]
        $robot.y+=$delta[1]
    }
    $RawPath+=$steps.ToString()

    # Check which direction we need to turn
    $turn = Turn-Direction
    if($turn -ne 0){
        $RawPath += $turn -eq 1 ? "R" : "L"
        $robot.dir = ($robot.dir + 4 + $turn ) % 4
    }
}while($turn -ne 0)


# Spit out the directions for now for me to look at
write-host $RawPath

<#
L 8 R 12 R 12 R 10 R 10 R 12 R 10 L 8 R 12 R 12 R 10 R 10 R 12 R 10 L 10 R 10 L 6 L 10 R 10 L 6 R 10 R 12 R 10 L 8 R 12 R 12 R 10 R 10 R 12 R 10 L 10 R 10 L 6

This could be an interesting compression problem, but by hand:

A = L,8,R,12,R,12,R,10
B = R,10,R,12,R,8
C = L,10,R,10,L6


#>


# }
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

