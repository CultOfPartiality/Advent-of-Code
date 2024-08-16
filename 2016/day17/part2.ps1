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

    $LongestPath = ""
    $LongestPathLength = 0

    $searchSpace = $searchSpace = New-Object 'System.Collections.Generic.PriorityQueue[psobject,int32]'

    $searchSpace.Enqueue($State, (Calc-Priority($State)) )
    while ( $searchSpace.count) {    
        $State = $searchSpace.Dequeue()
        $up, $down, $left, $right = (MD5 ($passcode + $State.path))[0..3] | % { ("b","c","d","e","f") -contains $_}
        if ($State.y -gt 0 -and $up) {
            $newState = [PSCustomObject]@{
                x    = $State.x
                y    = $State.y - 1
                path = $State.path + "U"
            }
            if ($newState.x -eq 3 -and $newState.y -eq 3) {
                if ($newState.path.Length -gt $LongestPathLength) {
                    $LongestPathLength = $newState.path.Length
                    $LongestPath = $newState.path
                    # write-host "New longest path of len $LongestPathLength found: $LongestPath"
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
                if ($newState.path.Length -gt $LongestPathLength) {
                    $LongestPathLength = $newState.path.Length
                    $LongestPath = $newState.path
                    # write-host "New longest path of len $LongestPathLength found: $LongestPath"
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
                if ($newState.path.Length -gt $LongestPathLength) {
                    $LongestPathLength = $newState.path.Length
                    $LongestPath = $newState.path
                    # write-host "New longest path of len $LongestPathLength found: $LongestPath"
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
                if ($newState.path.Length -gt $LongestPathLength) {
                    $LongestPathLength = $newState.path.Length
                    $LongestPath = $newState.path
                    # write-host "New longest path of len $LongestPathLength found: $LongestPath"
                }
            }
            else {
                $searchSpace.Enqueue($newState, (Calc-Priority($newState)))
            }
        }
    }
    $LongestPathLength
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 370
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 492
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" 830
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

