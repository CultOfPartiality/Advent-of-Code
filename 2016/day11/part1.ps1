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
    }
    function calc-hash {
        param($floors)
    
        return (
            "$($floors.Elevator)" +
            "1:" + ($floors[1].Objects | sort | join-string ) +
            "2:" + ($floors[2].Objects | sort | join-string ) +
            "3:" + ($floors[3].Objects | sort | join-string ) +
            "4:" + ($floors[4].Objects | sort | join-string )).GetHashCode()
    
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

    $searchSpace = New-Object 'System.Collections.Generic.PriorityQueue[psobject,int32]'
    # $searchSpace = New-Object System.Collections.Stack
    $previousStates = @{}
    $minSteps = [int32]::MaxValue
    $searchSpace.Enqueue($floors, $floors.Score)
    # $searchSpace.Push($floors)
    $previousStates[(calc-hash $floors)] = $floors.Step

    $debug = 0
    while ($searchSpace.Count) {
        $floors = $searchSpace.Dequeue()
        # $floors = $searchSpace.Pop()

        #We may have already been here, due to the priority queue, so we'll double check
        $hash = calc-hash $floors
        if ( $previousStates[$hash] -ne $null -and $previousStates[$hash] -lt $floors.Step) {
            continue
        }
        if ( $floors.Step -gt $minSteps) {
            continue
        }

        #Make each possible move and queue
        $currentFloor = $floors[$floors.Elevator]
        if ($currentFloor.Objects.Count -eq 0) {
            Write-Error "Error - Floor has no object"
            exit
        }
    
        #Get all the singles and pairs of objects
        $perms = (Get-AllPairs (@($currentFloor.Objects) + @("0")))  | % { , ($_ | ? { $_ -ne "0" }) }
        foreach ($perm in $perms) {
            #For each, check if we can go up or down without frying. If so, copy object, move elements, increment step and elevator, calc score, and enqueue
            1, -1 | % {
                if ( ($floors.Elevator + $_) -le 4 -and ($floors.Elevator + $_) -ge 1) {
                    $newFloors = copy-floors $floors
                    $newFloors.Elevator += $_
                    $upperFloor = $newFloors[$newFloors.Elevator]
                    $lowerFloor = $newFloors[$floors.Elevator]
                    $lowerFloor.objects = @($newFloors[$floors.Elevator].objects | ? { $_ -notin $perm })
                    $upperFloor.objects += $perm
                    $newFloors.Step++
                    #check floor above is totally safe
                    #check floor we left will be safe
                    ##DEBUG
                    # Write-host "Step:$($newFloors.Step), Elevator: $($newFloors.Elevator), Safe? $(IsFloor-Safe $upperFloor -and IsFloor-Safe $lowerFloor)";1..4 | %{
                    #     [PSCustomObject]@{
                    #         Floor = $_
                    #         From = $floors[$_].Objects
                    #         To = $newFloors[$_].Objects
                    # }} | Format-Table
                    if (IsFloor-Safe $upperFloor -and IsFloor-Safe $lowerFloor) {
                        calc-score $newFloors
                        $hash = calc-hash $newFloors

                        if ($newFloors.Score -eq 0) {
                            if ($newFloors.Step -lt $minSteps) {
                                $minSteps = $newFloors.Step
                                Write-Host "New min steps: $minSteps"
                            }
                        }
                        elseif ( ($previousStates[$hash] -eq $null -or $previousStates[$hash] -gt $newFloors.Step)) {
                            $previousStates[$hash] = $newFloors.Step
                            if ($newFloors.Step -lt $minSteps) {

                            
                                # Write-host "New Valid Step:$($newFloors.Step), Elevator: $($newFloors.Elevator)"
                                # 1..4 | %{
                                #     [PSCustomObject]@{
                                #         Floor = $_
                                #         From = $floors[$_].Objects
                                #         To = $newFloors[$_].Objects
                                # }} | Format-Table
                                    
                                $searchSpace.Enqueue($newFloors, $newFloors.Score)
                                # $searchSpace.Push($newFloors)
                            }
                        }
                    }
                }
            }
        }
        $debug++
        if ($debug % 100 -eq 0) {
            write-host "$($searchSpace.count) entries in queue, $($previousStates.Count) caches states"
        }
    
    }

    $minSteps


}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 11
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

