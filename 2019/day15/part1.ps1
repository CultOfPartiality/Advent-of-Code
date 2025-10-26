. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

# Reused IntCode computer this year
. "$PSScriptRoot\..\IntCodeComputer.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

function Solution {
    param ($Path)

    # Right and down are +ve

    enum Command {
        North = 1
        South = 2
        West = 3
        East = 4
    }

    $dirArray = [Command]::North, [Command]::East, [Command]::South, [Command]::West
    $RightTurnLookup = $null, [Command]::East, [Command]::West, [Command]::North, [Command]::South
    $LeftTurnLookup = $null, [Command]::West, [Command]::East, [Command]::South, [Command]::North

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
        x   = 0
        y   = 0
        dir = $dirArray[0] #North
    }
    $oxygen = [PSCustomObject]@{
        x = $null
        y = $null
    }
    $map = [PSCustomObject]@{
        hash = @{}
        x    = [PSCustomObject]@{Min = 0; Max = 0 }
        y    = [PSCustomObject]@{Min = 0; Max = 0 }
    }

    $memory = (get-content $Path) -split ',' | % { [int64]$_ } 
    $RepairDroneComp = [Computer]::New($memory)

    $map.hash["0,0"] = [PSCustomObject]@{
        x    = 0
        y    = 0
        type = [Block]::Floor
    }

    function sim-robot {
        $dir = $robot.dir.Value__
        $RepairDroneComp.RunComputer($dir)
        $x = $robot.x + ($dir -in 3, 4 ? ($dir * 2) - 7 : 0)
        $y = $robot.y + ($dir -in 1, 2 ? ($dir * 2) - 3 : 0)
        $map.x.Max = [math]::Max($map.x.Max, $x)
        $map.x.Min = [math]::Min($map.x.Min, $x)
        $map.y.Max = [math]::Max($map.y.Max, $y)
        $map.y.Min = [math]::Min($map.y.Min, $y)
        switch ([Status]$RepairDroneComp.OutputSignal) {
            ([Status]::HitWall) {
                $map.hash["$x,$y"] = [PSCustomObject]@{
                    x    = $x
                    y    = $y
                    type = [Block]::Wall
                }
            }
            ([status]::MovedOneStep) {
                $map.hash["$x,$y"] = [PSCustomObject]@{
                    x    = $x
                    y    = $y
                    type = [Block]::Floor
                }
                $robot.x = $x
                $robot.y = $y
            }
            ([status]::AtOxygenSystem) {
                $map.hash["$x,$y"] = [PSCustomObject]@{
                    x    = $x
                    y    = $y
                    type = [Block]::Oxygen
                }
                $robot.x = $x
                $robot.y = $y
                $oxygen.x = $x
                $oxygen.y = $y
            }
        }
    }

    # Move the robot in this direction, and back if necessary, to check for a wall
    function check-direction($dir) {
        $origDir = $robot.dir
        $robot.dir = $dir
        $wallInDir = $true
        sim-robot
        if ( [Status]$RepairDroneComp.OutputSignal -ne ([Status]::HitWall) ) {
            $wallInDir = $false
            $robot.dir = ($dir -in 1, 3) ? $dir + 1 : $dir - 1
            sim-robot
        }
        $robot.dir = $origDir
        $wallInDir
    }

    function print-map {
        write-host "`nCurrent Map:`n"
        $height = ($map.y.Max - $map.y.Min + 1)
        $width = ($map.x.Max - $map.x.Min + 1)
        $printMap = New-Object "int[,]" $width, $height
        foreach ($tile in $map.hash.Values) {
            $printMap[($tile.x - $map.x.Min), ($tile.y - $map.y.Min)] = $tile.type + 10
        }
        $printMap[($robot.x - $map.x.Min), ($robot.y - $map.y.Min)] = 99
        $printMap[(0 - $map.x.Min), (0 - $map.y.Min)] = 98
        for ($y = 0; $y -lt $height; $y++) {
            $row = ""
            for ($x = 0; $x -lt $width; $x++) {
                $row += switch ( $printMap[$x, $y] ) {
                    ([Block]::Floor + 10) { "." }
                    ([Block]::Wall + 10) { "█" }
                    ([Block]::Oxygen + 10) { "O" }
                    (98) { "S" }
                    (99) { "D" }
                    default { " " }
                }
            }
            write-host $row
        }
    }

    # Walk the full map to map it out
    1..1600 | % {
        $wallInFront = check-direction($robot.dir)
        $turnRightDir = $RightTurnLookup[$robot.dir]
        $turnLeftDir = $LeftTurnLookup[$robot.dir]
        $wallToRight = check-direction($turnRightDir)
        $wallToLeft = check-direction($turnLeftDir)
        if ($wallToRight -and $wallInFront) {
            $robot.dir = $LeftTurnLookup[$robot.dir]
        }
        elseif (!$wallToRight) {
            $robot.dir = $turnRightDir
        }
        sim-robot
    }
    # print-map



    # Convert the map to an array with a known 0,0 in the top left
    # -99 => Wall
    # -1 => Not yet walked
    # +ve number => steps from the end to get here
    $height = ($map.y.Max - $map.y.Min + 1)
    $width = ($map.x.Max - $map.x.Min + 1)
    $mapArray = New-Object "int[,]" $width, $height
    foreach ($tile in $map.hash.Values) {
        $mapArray[($tile.x - $map.x.Min), ($tile.y - $map.y.Min)] = ($tile.type -eq [Block]::Wall) ? -99 : -1
    }
    $startPoint = (0 - $map.x.Min), (0 - $map.y.Min)
    $endPoint = ($oxygen.x - $map.x.Min), ($oxygen.y - $map.y.Min)
    $mapArray[$endPoint] = 0

    $searchSpace = new-object "System.Collections.Queue"
    $searchSpace.Enqueue($endPoint)

    while ($searchSpace.Count) {
        $point = $searchSpace.Dequeue()
        $stepsToGetHere = $mapArray[$point]
        foreach ($delta in (-1, 0), (1, 0), (0, -1), (0, 1)) {
            $nextPoint = ($point[0] + $delta[0]), ($point[1] + $delta[1])
            $nextPointSteps = $mapArray[$nextPoint]
            if ($nextPointSteps -eq -1) {
                $mapArray[$nextPoint] = $stepsToGetHere + 1
                $searchSpace.Enqueue($nextPoint)
            }
        }
    }
    $mapArray[$startPoint]
}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

