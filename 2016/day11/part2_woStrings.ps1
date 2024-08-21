. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $setup = get-content $Path

    # -- The plan --
    # Need to generate a representation that enabled efficient checking of validity, and also moving data around for generating new states
    # If we can avoid deep objects, that'd be a plus too
    # Finally, our search optimisation needs work. The momoisation with chemical ambiguous state is a great start

    function Is-Valid ($state) {
        foreach ($floor in $state.objects) {
            $microchips = $floor.where({ $_ -gt 0 })
            if ($microchips -and $microchips.count -ne $floor.count) {
                #There are microchips and generators on the floor
                foreach ($microchip in $microchips) {
                    if (-$microchip -notin $floor) { return $false }
                }
            }
        }
        return $true
    }

    function Is-ValidLevel ($floor) {
        $microchips = $floor | ? { $_ -gt 0 }
        if ($microchips -and $microchips.count -ne $floor.count) {
            #There are microchips and generators on the floor
            foreach ($microchip in $microchips) {
                if (-$microchip -notin $floor) { return $false }
            }
        }
        return $true
    }

    function Is-WorthSearching ($state){
        #Once we've found a upper bound, we can eliminate a number of cases
        if ($minSteps -lt [int32]::MaxValue) {
            #Last turn checks
            $valid = switch ($state.Step) {
                #Last step (but last step for a solution better than what we've found so far, which will need to be an odd number to end up on floor 4):
                #   Elevator needs to be on level 3
                #   Third floor can't have more than 2 object
                #   The lower two levels can't have any objects
                ($minSteps - 3) {
                    ($state.Elevator -eq 2) -and
                    ($state.Objects[2].Count -eq 2) -and
                    ($state.Objects[1].Count -eq 0) -and
                    ($state.Objects[0].Count -eq 0)
                }
                ($minSteps - 4) {
                    ($state.Objects[0].Count -eq 0) -and
                    (($state.Objects[1].Count + $floors.Objects[2].Count) -eq 2)
                }
                Default { $true }
            }
            if (-not $valid) { return $false }
        }

        #Other things to check:
        #Taking a single object to level 4 means we need to just take it back down again...
        if ($state.Elevator -eq 3 -and $state.Objects[3].Count -eq 1) { return $false }
        #Going up to 3 with a single when level 4 is empty also means going back down
        if ($state.Elevator -eq 2 -and $state.Objects[2].Count -eq 1 -and $state.Objects[3].Count -eq 0) { return $false }
        if ($state.Elevator -eq 2 -and $state.Objects[2].Count -eq 1 -and ($state.Objects[1].Count+$state.Objects[0].Count) -eq 0) { return $false }
        #Going down to 2 with a single when level 1 is empty also means going back up
        if ($state.Elevator -eq 1 -and $state.Objects[1].Count -eq 1 -and $state.Objects[0].Count -eq 0) { return $false }
        if ($state.Elevator -eq 1 -and $state.Objects[1].Count -eq 1 -and ($state.Objects[2].Count+$state.Objects[3].Count) -eq 0) { return $false }
        #Taking a single object to level 1 means we need to just take it back up again...
        if ($state.Elevator -eq 0 -and $state.Objects[0].Count -eq 1) { return $false }

        return $true
    }

    function Gen-Hash ($state) {
        $hash = [string]$state.elevator + ","
        foreach ($floor in $state.objects) {
            $hash += ($floor | sort | % { $_ -gt 0 ? "M" : "G" } | Join-String) + ","
        }
        $hash
    }

    function Calc-Score ($state) {
        $score = 0
        for ($i = 0; $i -lt 3; $i++) {
            $score += $state.objects[$i].Count * (3 - $i)
        }
        $score
    }

    function Possible-Moves ($state) {
        $pairs = Get-AllPairs ($state.Objects[$state.elevator] + 0) | % { , $_.where({ $_ }) }
        $newElevators = switch ($state.elevator) {
            0 { @(, 1) }
            3 { @(, 2) }
            Default { @(($state.elevator - 1), ($state.elevator + 1)) }
        } 
        foreach ($newElevator in $newElevators) {
            foreach ($pair in $pairs) {
                $oldLevelObjects = [array]($state.objects[$state.elevator] | ? { $_ -notin $pair })
                $newLevelObjects = [array]($state.objects[$newElevator] + $pair)
                if ( (Is-ValidLevel($oldLevelObjects)) -and (Is-ValidLevel($newLevelObjects))) {
                    $newState = [PSCustomObject]@{
                        elevator = $newElevator
                        steps    = $state.steps + 1
                        objects  = $state.objects.Clone()
                    }
                    $newState.objects[$state.elevator] = [array]$oldLevelObjects
                    $newState.objects[$newElevator] = [array]$newLevelObjects
                    $newState
                }
            }
        }
    }

    $state = [PSCustomObject]@{
        elevator = 0
        steps    = 0
        # objects  = @(1, 2), @(-1), @(-2), @() #for test question
        # objects  = @(1, -1), @(-2,-3,-4,-5), @(2,3,4,5), @() #for part 1 input
        objects  = @(1, -1,6,7,-6,-7), @(-2,-3,-4,-5), @(2,3,4,5), @() #for part 2 input
    }
    $cache = @{}
    $minSteps = [int32]::MaxValue
    $searchSpace = New-Object 'System.Collections.Generic.PriorityQueue[psobject,int32]'
    $searchSpace.Enqueue($state, (Calc-Score($state)) )

    while ($searchSpace.Count) {
        $state = $searchSpace.Dequeue()
        # If the next step can't beat the best by at least 2, then it's no better
        if($state.steps+1 -gt $minSteps-2){continue}
        $newStates = Possible-Moves($state)
        foreach ($newState in $newStates) {
            $hash = Gen-Hash($newState)
            if ($cache.ContainsKey($hash) -and $cache[$hash] -le $newState.steps) { continue }
            $cache[$hash] = $newState.steps
            if(-not (Is-WorthSearching($newState))){continue}
            $score = Calc-Score($newState)
            if ($score -eq 0) {
                if ($newState.steps -lt $minSteps) {
                    $minSteps = $newState.steps
                    write-host "New min steps: $minSteps"
                }
            }
            else {
                $searchSpace.Enqueue($newState, $score)
            }
        }
    }
    $minSteps
    
}
# $measuredTime = measure-command { Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 11 }
# Write-Host "Test 1`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Green
$measuredTime = measure-command { Unit-Test  ${function:Solution} "$PSScriptRoot/input.txt" 57 }
Write-Host "Part 2`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Green

# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# #The answer is 33, but we need to optimise more, especially for part 2
# Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

