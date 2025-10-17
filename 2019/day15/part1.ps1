. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

# Reused IntCode computer this year
. "$PSScriptRoot\..\IntCodeComputer.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

#function Solution {
#    param ($Path)

# Right and down are +ve

enum Command {
    North = 1
    South = 2
    West = 3
    East = 4
}

$dirArray = [Command]::North,[Command]::East,[Command]::South,[Command]::West

enum Status {
    HitWall = 0
    MovedOneStep = 1
    AtOxygenSystem = 2
}

enum Block {
    Floor = 0
    Wall = 1
    Oxygen = 2
}

$robot = [PSCustomObject]@{
    x = 0
    y = 0
    dir = $dirArray[0]
}
$map = [PSCustomObject]@{
    hash = @{}
    x = [PSCustomObject]@{Min = 0; Max = 0}
    y = [PSCustomObject]@{Min = 0; Max = 0}
}

$memory = (get-content $Path) -split ',' | % { [int64]$_ } 
$RepairDroneComp = [Computer]::New($memory)

$map.hash["0,0"] = [PSCustomObject]@{
    x = 0
    y = 0
    type = [Block]::Floor
}

function sim-robot{
    $dir = $robot.dir.Value__
    $RepairDroneComp.RunComputer($dir)
    $x = $robot.x + ($dir -in 3,4 ? ($dir*2)-7 : 0)
    $y = $robot.y + ($dir -in 1,2 ? ($dir*2)-3 : 0)
    $map.x.Max = [math]::Max($map.x.Max,$x)
    $map.x.Min = [math]::Min($map.x.Min,$x)
    $map.y.Max = [math]::Max($map.y.Max,$y)
    $map.y.Min = [math]::Min($map.y.Min,$y)
    switch([Status]$RepairDroneComp.OutputSignal){
        ([Status]::HitWall) {
            $map.hash["$x,$y"] = [PSCustomObject]@{
                x = $x
                y = $y
                type = [Block]::Wall
            }
        }
        ([status]::MovedOneStep) {
            $map.hash["$x,$y"] = [PSCustomObject]@{
                x = $x
                y = $y
                type = [Block]::Floor
            }
            $robot.x = $x
            $robot.y = $y
        }
        ([status]::AtOxygenSystem) {
            $map.hash["$x,$y"] = [PSCustomObject]@{
                x = $x
                y = $y
                type = [Block]::Oxygen
            }
            $robot.x = $x
            $robot.y = $y
        }
    }
}

function print-map{
    write-host "`nCurrent Map:`n"
    $height = ($map.y.Max - $map.y.Min + 1)
    $width = ($map.x.Max - $map.x.Min + 1)
    $printMap = New-Object "int[,]" $width,$height
    foreach($tile in $map.hash.Values){
        $printMap[($tile.x - $map.x.Min),($tile.y-$map.y.Min)] = $tile.type + 10
    }
    $printMap[($robot.x - $map.x.Min),($robot.y-$map.y.Min)] = 99
    for ($y = 0; $y -lt $height; $y++) {
        $row = ""
        for ($x = 0; $x -lt $width; $x++) {
            $row += switch( $printMap[$x,$y] ){
                ([Block]::Floor +10) {"."}
                ([Block]::Wall  +10) {"#"}
                ([Block]::Oxygen+10) {"O"}
                (99) {"D"}
                default {" "}
            }
        }
        write-host $row
    }
}

# We'll walk the robot around, always turning right when we can
1..10000 | %{
    sim-robot
    $robot.dir = $dirArray[(0..3 | Get-Random)]
}



print-map
#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

