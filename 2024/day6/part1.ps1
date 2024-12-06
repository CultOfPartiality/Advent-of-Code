. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

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
                $guard.x = $x
                $guard.y = $y
                $guard.dir = 0 #up
                $visited["$y,$x"] = 1
            }
        }
    }

    #Up, Right, Down, Left
    $dirLookup = @( @(-1, 0), @(0, 1), @(1, 0), @(0, -1))

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
                $visited["$($guard.y),$($guard.x)"]++
            }
            else {
                break
            }
        }
    }
    $visited.Values.Count

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 41
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

