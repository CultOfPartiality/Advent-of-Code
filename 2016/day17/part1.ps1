. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)


    $passcode = get-content $Path

    $State = [PSCustomObject]@{
        x    = 0
        y    = 0
        path = ""
    }

    function Calc-Priority ($State) {
        6 - ($State.x + $State.y)
    }

    $shortestPath = ""
    $shortestPathLength = [int32]::MaxValue

    $searchSpace = $searchSpace = New-Object 'System.Collections.Generic.PriorityQueue[psobject,int32]'

    $searchSpace.Enqueue($State, (Calc-Priority($State)) )
    while ( $searchSpace.count) {    
        $State = $searchSpace.Dequeue()
        if ($State.path.Length -ge $shortestPathLength) { continue }
        $up, $down, $left, $right = (MD5 ($passcode + $State.path))[0..3] | % { ("b","c","d","e","f") -contains $_}
        if ($State.y -gt 0 -and $up) {
            $newState = [PSCustomObject]@{
                x    = $State.x
                y    = $State.y - 1
                path = $State.path + "U"
            }
            if ($newState.x -eq 3 -and $newState.y -eq 3) {
                if ($newState.path.Length -lt $shortestPathLength) {
                    $shortestPathLength = $newState.path.Length
                    $shortestPath = $newState.path
                    write-host "New shortest path of len $shortestPathLength found: $shortestPath"
                }
            }
            else {
                $searchSpace.Enqueue($newState, (Calc-Priority($newState)))
            }
        }
        if (($State.y -lt 3) -and $down) {
            $newState = [PSCustomObject]@{
                x    = $State.x
                y    = $State.y + 1
                path = $State.path + "D"
            }
            if ($newState.x -eq 3 -and $newState.y -eq 3) {
                if ($newState.path.Length -lt $shortestPathLength) {
                    $shortestPathLength = $newState.path.Length
                    $shortestPath = $newState.path
                    write-host "New shortest path of len $shortestPathLength found: $shortestPath"
                }
            }
            else {
                $searchSpace.Enqueue($newState, (Calc-Priority($newState)))
            }
        }
        if ($State.x -gt 0 -and $left) {
            $newState = [PSCustomObject]@{
                x    = $State.x - 1
                y    = $State.y
                path = $State.path + "L"
            }
            if ($newState.x -eq 3 -and $newState.y -eq 3) {
                if ($newState.path.Length -lt $shortestPathLength) {
                    $shortestPathLength = $newState.path.Length
                    $shortestPath = $newState.path
                    write-host "New shortest path of len $shortestPathLength found: $shortestPath"
                }
            }
            else {
                $searchSpace.Enqueue($newState, (Calc-Priority($newState)))
            }
        }
        if (($State.x -lt 3) -and $right) {
            $newState = [PSCustomObject]@{
                x    = $State.x + 1
                y    = $State.y
                path = $State.path + "R"
            }
            if ($newState.x -eq 3 -and $newState.y -eq 3) {
                if ($newState.path.Length -lt $shortestPathLength) {
                    $shortestPathLength = $newState.path.Length
                    $shortestPath = $newState.path
                    write-host "New shortest path of len $shortestPathLength found: $shortestPath"
                }
            }
            else {
                $searchSpace.Enqueue($newState, (Calc-Priority($newState)))
            }
        }
    }
    $shortestPath
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" "DDRRRD"
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" "DDUDRLRRUDRD"
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" "DRURDRUDDLLDLUURRDULRLDUUDDDRR"
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

