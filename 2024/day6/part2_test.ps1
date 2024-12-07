. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"


# Tried to keep track of the previous location (in a kinda dodgy way), but the passing of classes and what
# not means this is actually slower...


function Solution {
    param ($Path)


    $data = get-content $Path

    $walls = @{}
    $guard = @{}
    $visited = @{}
    for ($y = 0; $y -lt $data.Count; $y++) {
        for ($x = 0; $x -lt $data[0].Length; $x++) {
            if ($data[$y][$x] -eq "#") {
                $walls["$y,$x"] = 1
            }
            elseif ($data[$y][$x] -eq "^") {
                $guard.coord = [Coords]($y, $x)
                $guard.dir = 0 #up
                $visited["$y,$x"] = @{dir = 0; step = 0 }
            }
        }
    }


    #Returns if guard is in a loop
    function Sim-Guard {
        param(
            $origGuard,
            $originalWalls,
            $newWall
        )
        #Need to build a linked list, so after the first round we can reference the previous
        $visited = @{}
        $guard = $origGuard.Clone()
        $walls = $originalWalls.Clone()
        $loop = $false
        #add the new wall
        $walls[$newWall.Hash()] = 1

        #Deltas for the current direction: Up, Right, Down, Left
        $dirLookup = @( @(-1, 0), @(0, 1), @(1, 0), @(0, -1))

        $step = 0
        while ($true) {
            #Check ahead
            $aheadDelta = $dirLookup[$guard.dir]
            $ahead = $guard.coord + $aheadDelta
            if ($walls.ContainsKey($ahead.Hash())) {
                $guard.dir = ($guard.dir + 1) % 4
            }
            else {
                if (
                    $ahead.col -ge 0 -and $ahead.row -ge 0 -and
                    $ahead.col -lt $data.Count -and $ahead.row -lt $data[0].Length
                ) {
                    $step++
                    $guard.coord = $ahead
                    $status = @{coord = $guard.coord; dir = $guard.dir; step = $step }

                    if ($visited.ContainsKey($ahead.Hash())) {
                        if ($visited[$ahead.Hash()].dir -contains $guard.dir) {
                            $loop = $true
                            break
                        }
                        else {
                            $visited[$ahead.Hash()] += $status
                        }
                    }
                    else {
                        $visited[$ahead.Hash()] = , $status
                    }
                    
                }
                else {
                    break
                }
            }
        }
        return ($visited, $loop)
    }
    
    $visited, $_ = Sim-Guard -origGuard $guard -originalWalls $walls -newWall ([Coords](-1, -1))

    $causedALoop = 0
    $checked = 0
    
    # Need to remove starting square
    $possibleObstructions = $visited.Keys | ? { $_ -ne "$($guard.y),$($guard.x)" }
    foreach ($possibleObstruction in $possibleObstructions) {
        $checked++
        write-host "Checking $checked/$($visited.Count)" 
        $newWall = $possibleObstruction -split "," | % { [int]$_ }
        
        #Need to start the guard just before the new obstructions to reduce computation time?
        $obstrctionStep = $visited[$possibleObstruction].step | sort | select -First 1
        if ($obstrctionStep -ne 1) {
            $prevNode = ($visited.Values | ? { $_.step -eq ($obstrctionStep - 1) } | sort { $_.step })[0]
            $newGuard = @{ 
                coord = $prevNode.Coord
                dir   = $prevNode.dir
                step  = $prevNode.step
            }
        }
        else{ #only for if we're putting the obstruction right in front...
            $newGuard = $guard
        }
        
        $_, $loop = Sim-Guard -origGuard $newGuard -originalWalls $walls -newWall ([Coords]$newWall)
        if ($loop) {
            write-host "  Loop!" -ForegroundColor Green
            $causedALoop++
        }
    }
    #Output the number that caused a loop
    $causedALoop
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 6
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

