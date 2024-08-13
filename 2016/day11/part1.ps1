. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)


    $setup = get-content $Path

    <#Rules
 - Chips can only be on the same floor as RTGs if their matching RTG is on the same floor
 - Elevator can carry two objects
 - Elevator must have at least one object to move between floors
 - Get all objects to top floor
#>

    function calc-score {
        param($floors)
        $floors.Score = 6 * $floors[1].Objects.Count + 3 * $floors[2].Objects.Count + 1 * $floors[3].Objects.Count
        #$floors.Score = 2 * $floors[1].Objects.Count + 2 * $floors[2].Objects.Count + 2 * $floors[3].Objects.Count
    }

    function calc-hash {
        param($floors)
    
        return (
            "$($floors.Elevator)_" +
            "_1:" + ($floors[1].Objects | sort | join-string ) +
            "_2:" + ($floors[2].Objects | sort | join-string ) +
            "_3:" + ($floors[3].Objects | sort | join-string ) +
            "_4:" + ($floors[4].Objects | sort | join-string )).GetHashCode()
    
    }

    function Print-Floors {
        param ($oldFloors, $newFloors)
        Write-host "New Valid Step:$($newFloors.Step) (current best is $minSteps), Elevator: $($newFloors.Elevator)"
        4..1 | % {
            [PSCustomObject]@{
                Floor    = $_
                Elevator = $newFloors.Elevator -eq $_ ? "E" : ($oldFloors.Elevator -eq $_ ? "*":"")
                From     = $oldFloors[$_].Objects
                To       = $newFloors[$_].Objects
            } } | Format-Table | out-string | % { write-host $_ }
        
    }

    function copy-floors {
        param($floors)
        @{
            Elevator = $floors.Elevator
            Step     = $floors.Step
            Score    = $floors.Score
            1        = $floors[1].psobject.Copy()
            2        = $floors[2].psobject.Copy()
            3        = $floors[3].psobject.Copy()
            4        = $floors[4].psobject.Copy()
        }
    }

    function IsFloor-Safe {
        param($floor)
        $generators = $floor.objects | ? { $_ -match "Gn_" } | % { $_.SubString(3) }
        $microchips = $floor.objects | ? { $_ -match "MC_" } | % { $_.SubString(3) }
        #If no generators on the level, it'll be safe
        if ($generators.count -eq 0) { return $true }
        #If all chips match a generator, it'll be safe
        $unmatchedChips = $microchips | ? { $_ -notin $generators }
        if ($unmatchedChips.count -eq 0) { return $true }
        #Otherwise, it's not safe
        return $false
    }

    function IsValid-Case {
        param($floors, $prevElevator)
        
        #Check floors we've just moved things around on are safe
        if (-not (IsFloor-Safe $floors[$floors.Elevator])) { return $false }
        if (-not (IsFloor-Safe $floors[$prevElevator])) { return $false }
        #Once we've found a upper bound, we can eliminate a number of cases
        if ($minSteps -lt [int32]::MaxValue) {
            #Last turn checks
            $valid = switch ($floors.Step) {
                #Last step (but last step for a solution better than what we've found so far, which will need to be an odd number to end up on floor 4):
                #   Elevator needs to be on level 3
                #   Third floor can't have more than 2 object
                #   The lower two levels can't have any objects
                ($minSteps - 3) {
                    ($floors.Elevator -eq 3) -and
                    ($floors[3].Objects.Count -le 2) -and
                    ($floors[2].Objects.Count -eq 0) -and
                    ($floors[1].Objects.Count -eq 0)
                }
                ($minSteps - 4) {
                    ($floors[1].Objects.Count -eq 0) -and
                    ($floors[2].Objects.Count + $floors[3].Objects.Count -lt 2)
                }
                Default { $true }
            }
            if (-not $valid) { return $false }
        }

        #Other things to check:
        #Taking a single object to level 4 means we need to just take it back down again...
        if ($floors.Elevator -eq 4 -and $floors[4].Objects.Count -eq 1) { return $false }

        return $true
    }


    $floors = @{
        Elevator = 1
        Step     = 0
        Score    = 0
    }
    1..4 | % {
        $floors[$_] = [PSCustomObject]@{
            Floor   = $_
            Objects = @()
        }
    }
    foreach ($floorIndex in 1..4) {
        $floorDetails = $setup[$floorIndex - 1]
        $microchips = ($floorDetails | Select-String -AllMatches "(\w*)-compatible microchip").Matches
        foreach ($microchip in $microchips) {
            $floors[$floorIndex].Objects += ("MC_" + $microchip.Groups[1].Value)
        }
        $generators = ($floorDetails | Select-String -AllMatches "(\w*) generator").Matches
        foreach ($generator in $generators) {
            $floors[$floorIndex].Objects += ("Gn_" + $generator.Groups[1].Value)
        }
    }
    calc-score -floors $floors

    # $searchSpace = New-Object 'System.Collections.Generic.PriorityQueue[psobject,int32]'
    $searchSpace = New-Object System.Collections.Stack
    $previousStates = @{}
    $minSteps = [int32]::MaxValue
    # $searchSpace.Enqueue($floors, $floors.Score)
    $searchSpace.Push($floors)
    $previousStates[(calc-hash $floors)] = $floors.Step

    $debug = 0
    while ($searchSpace.Count) {
        # $floors = $searchSpace.Dequeue()
        $floors = $searchSpace.Pop()

        #We may have already been here in less steps, due to the priority queue, so we'll double check
        $hash = calc-hash $floors
        if ( ($null -ne $previousStates[$hash]) -and ($previousStates[$hash] -lt $floors.Step)) {continue}
        #We also should just discard any steps that have reached the min steps
        if ( $floors.Step -ge $minSteps) {continue}

        #Make each possible move and queue (moving singles and pairs)
        $perms = (Get-AllPairs (@($floors[$floors.Elevator].Objects) + @("0")))  | % { , ($_ | ? { $_ -ne "0" }) }
        foreach ($perm in $perms) {
            #For each, check if we can go up or down without frying. If so, copy object, move elements, increment step and elevator, calc score, and enqueue
            foreach($ElevatorMovement in (1, -1)){
                if ( ($floors.Elevator + $ElevatorMovement) -le 4 -and ($floors.Elevator + $ElevatorMovement) -ge 1) {
                    $newFloors = copy-floors $floors
                    $newFloors.Elevator += $ElevatorMovement
                    $upperFloor = $newFloors[$newFloors.Elevator]
                    $lowerFloor = $newFloors[$floors.Elevator]
                    $lowerFloor.objects = @($newFloors[$floors.Elevator].objects | ? { $_ -notin $perm })
                    $upperFloor.objects += $perm
                    $newFloors.Step++


                    #Debug - Check for example state (found steps 1-3, step 4 not found until later on, like step 12....)
                    # if( $newFloors.Elevator -eq 2 -and
                    #     $newFloors.Step -eq 3 -and
                    #     "MC_hydrogen" -in $newFloors[2].Objects -and
                    #     "MC_lithium" -in $newFloors[1].Objects -and
                    #     "Gn_hydrogen" -in $newFloors[3].Objects -and
                    #     "Gn_lithium" -in $newFloors[3].Objects
                    #     ){
                    #     Write-host "Found example state!" -ForegroundColor Cyan
                    #     Print-Floors $floors $newFloors
                    #     $z=$z
                    # }

                    if ($newFloors.Step -ge $minSteps) {
                        # Write-host "The following was discarded due to having a higher step count than the minimum finsish seen so far" -ForegroundColor Blue
                        # Print-Floors $floors $newFloors
                        continue
                    }

                    #Skip it if we've cached the results, otherwise add to cache (valid or not)
                    $hash = calc-hash $newFloors
                    if (($null -ne $previousStates[$hash]) -and
                        ($previousStates[$hash] -le $newFloors.Step) ) { 
                        # Write-host "The following was discarded due to having reached this state previously, with the same or smaller step count ($($previousStates[$hash]))" -ForegroundColor Blue
                        # Print-Floors $floors $newFloors
                        continue
                    }

                    $previousStates[$hash] = $newFloors.Step
                    
                    #If it's a valid position we'll think about adding it back to the queue
                    if ( IsValid-Case -floors $newFloors -prevElevator $floors.Elevator) {
                        calc-score $newFloors
                        #We've checked the step count, so if the score is 0 we've got a new winner, else add it back to the queue
                        if ($newFloors.Score -eq 0) {
                            $minSteps = $newFloors.Step
                            Write-Host "New min steps: $minSteps"
                        }
                        else {
                            # $searchSpace.Enqueue($newFloors, $newFloors.Score)
                            $searchSpace.Push($newFloors)
                        
                        }
                    }
                }
            }
        }
        $debug += ($perms.Count) * 2
        if ($debug % 100 -eq 0) {
            write-host "$debug entries checked, $($searchSpace.count) entries in queue, $($previousStates.Count) caches states, best case=$minSteps"
        }
    
    }

    $minSteps


}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 11
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
