. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"


<#
    This fella is certainly not optimised, takes ~2 minutes to run. 
    Keeping track of the previous path and starting off right before an obsticle wasn't quite it.
    Maybe keeping track of all routes, and check for loops that way? Maybe the overhead from the Hash's is the issue?
#>

function Solution {
    param ($Path)

    # Parse the map, and locate the guard
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
                $guard.x = $x
                $guard.y = $y
                $guard.dir = 0 #up
                $visited["$y,$x"] = 0 #up
            }
        }
    }


    #A functon to check the visited squares of a guard's path, and returns if guard is in a loop
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
        $walls["$($newWall[0]),$($newWall[1])"] = 1

        #Deltas for the current direction: Up, Right, Down, Left
        $dirLookup = @( @(-1, 0), @(0, 1), @(1, 0), @(0, -1))

        #Sim the first round
        while ($true) {
            #Check ahead
            $aheadDelta = $dirLookup[$guard.dir]
            $ahead = ($guard.y + $aheadDelta[0]), ($guard.x + $aheadDelta[1])
            if ($walls.ContainsKey("$($ahead[0]),$($ahead[1])")) {
                $guard.dir = ($guard.dir + 1) % 4
            }
            else {
                if ($ahead[0] -ge 0 -and $ahead[1] -ge 0 -and $ahead[1] -lt $data[0].Length -and $ahead[0] -lt $data.Count) {
                    $guard.y = $ahead[0]
                    $guard.x = $ahead[1]
                    if($visited["$($guard.y),$($guard.x)"] -eq $guard.dir){
                        $loop = $true
                        break
                    }
                    $visited["$($guard.y),$($guard.x)"] = $guard.dir
                }
                else {
                    break
                }
            }
        }
        return ($visited,$loop)
    }
    
    #Run the initial state of the guard
    $visited,$_ = Sim-Guard -origGuard $guard -originalWalls $walls -newWall (-1,-1)

    # Run each square on the path (except for the starting square) as if it was an obstruction, and check for a loop
    $causedALoop = 0
    $checked = 0
    $possibleObstructions = $visited.Keys | ?{$_ -ne "$($guard.y),$($guard.x)"}
    foreach ($possibleObstruction in $possibleObstructions) {
        $checked++
        $newWall = $possibleObstruction -split "," | %{[int]$_}
        $_,$loop = Sim-Guard -origGuard $guard -originalWalls $walls -newWall $newWall
        if($loop){
            $causedALoop++
        }
    }

    #Output the number of obstructions that caused a loop
    $causedALoop

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 6
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

