. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)


    $data = get-content $Path | select -Skip 2
    $uid = 0
    $nodes = $data | % {
        $parts = $_ -split "\s+"
        [PSCustomObject]@{
            Name   = $parts[0]
            X      = [int][regex]::Match($parts[0], "x(\d+)").Groups[1].Value
            Y      = [int][regex]::Match($parts[0], "y(\d+)").Groups[1].Value
            UID    = $uid++
            Size   = [int]$parts[1].TrimEnd("T")
            Used   = [int]$parts[2].TrimEnd("T")
            Avail  = [int]$parts[3].TrimEnd("T")
            UsePer = ( [int]$parts[4].TrimEnd("%") ) / 100.0
        }
    }
    $maxX = ( $nodes.X | Measure-Object -Maximum ).Maximum
    $maxY = ( $nodes.Y | Measure-Object -Maximum ).Maximum

    # Could fit 2 lots of data in one node? -NO
    #   All viable data is between 64 and 73
    #   Biggest available space is 89, all others less than 30
    #
    # Thus the example is valid, we're just moving the empty space around, and there are actual blockers
    # Convert to a smaller representation, so we can hold the game state and do a depth first search:
    #   Store the blocker locations in a list
    #   Then each state we only need to keep track of the coords of the data we want, and the empty node

    $maxAvailable = ( $nodes.Avail | Measure-Object -Maximum).Maximum
    $blockerNodes = New-Object "Boolean[,]" ($maxX + 1), ($maxY + 1)
    $nodes | ? { $_.Used -gt $maxAvailable } | % {
        $blockerNodes[$_.X, $_.Y] = $true
    }
    $startingEmptyNode = $nodes | ? { $_.Used -eq 0 }

    $gameState = [PSCustomObject]@{
        Data  = ( @($maxX, 0) )
        Empty = @($startingEmptyNode.X, $startingEmptyNode.Y)
        Steps = 0
    }


    # Spin up a search space, where the priority is the distance of the data from the goal of 0,0
    # Add the first position to this queue, then keep searching while the queue still has data
    # If we're ever in a state that has more steps than the best one we've found, then discard
    # We'll also keep track of states seen, in a hash, with the step count. If we've made it to a known state in more steps, then discard
    $minSteps = [int32]::MaxValue
    $cache = @{}
    function Hash ($gameState) { ( "$($gameState.Data),$($gameState.Empty)" ).GetHashCode() }
    function Score ($gameState) {
        $gameState.Data[0] + $gameState.Data[1] + 
        [Math]::Abs($gameState.Data[0] - $gameState.Empty[0]) + 
        [Math]::Abs($gameState.Data[1] - $gameState.Empty[1]) 
    }
    $searchSpace = New-Object 'System.Collections.Generic.PriorityQueue[psobject,int32]'
    $searchSpace.Enqueue($gameState, 0)

    while ($searchSpace.Count) {
        $gameState = $searchSpace.Dequeue()
        # If we've found a viable solution, throw away any starting point where the next step  isn't at least 1 better
        # After that, throw away any starting point we've been to in less steps (priority queue may loop back on itself)
        if ( ($gameState.Steps + 1) -ge ($minSteps - 1)) { continue }
        $hash = Hash($gameState)
        if ($cache.ContainsKey($hash) -and $cache[$hash] -lt $gameState.Steps) { continue }
        $cache[$hash] = $gameState.Steps
        # Work out the next states, by moving one in each direction
        #   New empty is old empty plus the delta
        #   If the new empty is the old data, then data is the old empty, otherwise old data is the same
        # If there's a blocker, or the node would be off the edge of the "map", then discard
        # Then check the state against the cache. Again, if we've made it here previously in less steps, discard
        # Finally, check if the node is the end. If so, and we made it here in less steps, then update the $minSteps. Otherwise, add the state to the queue
        foreach ($delta in ((0, 1), (0, -1), (1, 0), (-1, 0))) {
            $newEmpty = @( ($gameState.Empty[0] + $delta[0]), ($gameState.Empty[1] + $delta[1]) ) 
            $newData = ($newEmpty[0] -eq $gameState.Data[0] -and $newEmpty[1] -eq $gameState.Data[1]) ? $gameState.Empty : $gameState.Data
            $newGameState = [PSCustomObject]@{
                Data  = $newData.Clone()
                Empty = $newEmpty.Clone()
                Steps = $gameState.Steps + 1
            }
            if ( $newGameState.Empty[0] -gt $maxX -or $newGameState.Empty[0] -lt 0 ) { continue }
            if ( $newGameState.Empty[1] -gt $maxY -or $newGameState.Empty[1] -lt 0 ) { continue }
            if ( $blockerNodes[$newGameState.Empty]) { continue }
            $hash = Hash($newGameState)
            if ($cache.ContainsKey($hash) -and $cache[$hash] -le $newGameState.Steps) { continue }
            $cache[$hash] = $newGameState.Steps
            if ($newGameState.Data[0] -eq 0 -and $newGameState.Data[1] -eq 0) {
                if ($newGameState.Steps -lt $minSteps) {
                    $minSteps = $newGameState.Steps
                    Write-Host "New min steps: $minSteps"
                }
            }
            else {
                $searchSpace.Enqueue($newGameState, (Score($newGameState)) )
            }
        }
    
    }
    $minSteps
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 7
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
#420 is too high
