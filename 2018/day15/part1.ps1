. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)


    # Parse the data into map and combatants
    #   Map stored in hashtable, create as doubly linked graph
    #   Also store if combatant there with a double link
    #   Combatants stored in their own array, and we can order these in reading order

    $rawdata = get-content $Path

    $map = @{}
    $walls = @{}
    $combatants = @()
    $rows = $rawdata.Length
    $cols = $rawdata[0].Length
    for ($y = 0; $y -lt $rows; $y++) {
        for ($x = 0; $x -lt $cols; $x++) {
            $coord = [Coords]($y, $x)
            $cell = $rawdata[$y][$x]
            # Add to map
            if ($cell -ne "#") {
                $mapTile = [PSCustomObject]@{
                    Coord = $coord
                    Links = @()
                    Unit  = $null
                    dist  = $null
                    prev  = $null
                }
                foreach ($delta in (-1, 0), (1, 0), (0, -1), (0, 1) ) {
                    $neighbourCoord = $coord + $delta
                    if ($neighbourCoord.Contained($rows, $cols) -and
                        $rawdata[$neighbourCoord.row][$neighbourCoord.col] -ne "#") {
                        $mapTile.Links += $neighbourCoord
                    }
                }

                $map[$coord.Hash()] = $mapTile
            }
            else {
                $walls[$coord.Hash()] = $coord
            }
            # Add to combatants
            if ($cell -in "G", "E") {
                $combatants += [PSCustomObject]@{
                    Team   = $cell
                    Coord  = $coord
                    Health = 200
                }
                $map[$coord.Hash()].Unit = $combatants[-1]
            }
        }
    }
    # Change links from coords to objs
    foreach ($mapTile in $map.Values) {
        $mapTile.Links = $map.Values | ? { $_.Coord -in $mapTile.Links }
    }

    function print-map() {
        $printMap = New-Object "char[,]" $rows, $cols
        $map.Values | % {
            $printMap[$_.Coord.Array()] = "."
        }
        $walls.Values | % {
            $printMap[$_.Array()] = "#"
        }
        $combatants | % {
            $printMap[$_.Coord.Array()] = $_.Team
        }

        for ($y = 0; $y -lt $rows; $y++) {
            $rowdata = ""
            for ($x = 0; $x -lt $cols; $x++) {
                $rowdata += $printMap[$y, $x]
            }
            write-host $rowdata -ForegroundColor DarkGray
        }
    }

    function dikstras($graph, $startNode) {

        $q = New-Object "System.Collections.Generic.PriorityQueue[psobject,int]"

        $startNode.dist = 0
        $q.Enqueue($startNode, 0)

        while ($q.Count) {
            $fromNode = $q.Dequeue()
            foreach ($toNode in $fromNode.links) {
                if ($toNode.Unit) { continue } # Someone's standing here, move on
                $alt = $fromNode.dist + 1
                if (
                    $null -eq $toNode.dist -or #neighbour hasn't been visited
                    $alt -lt $toNode.dist -or #We've gotten here in a shorter time than last time
                    (
                        $toNode.dist -eq $alt -and (
                        ($fromNode.Coord.row -lt $toNode.prev.Coord.row) -or
                        ($fromNode.Coord.row -eq $toNode.prev.Coord.row -and $fromNode.Coord.col -lt $toNode.prev.Coord.col)
                        )
                    ) # We've equaled the distance, but come from a square that's smaller in "reading order"
                ) {
                    $toNode.prev = $fromNode
                    $toNode.dist = $alt
                    $q.Enqueue($toNode, $toNode.dist) 
                }
            }
        }
    }

    function calc-movedirection($unit) {
        # Need to start at the units location and move out from there
        foreach ($mapTile in $map.Values) {
            $mapTile.prev = $null
            $mapTile.dist = $null
        }

        dikstras $map $map[$unit.Coord.Hash()] 

        $enemyTiles = $map.Values | ? { $null -eq $_.dist } | ? { $_.Unit.Team -eq ($unit.Team -eq "G" ? "E":"G") }
        $availableNextToEnemy = $enemyTiles.Links | ? { $_.dist } | ? { $_.dist } | Sort-Object dist, { $_.Coord.row }, { $_.Coord.col }

        #Now just walk back through the links, find the squares that can be stepped on
        #Break ties, then move
        #update map unit links
        if ($availableNextToEnemy.Count -lt 1) {
            return
        }
        $cell = $availableNextToEnemy[0]
        while ($cell.dist -gt 1) { $cell = $cell.prev }

        #Diktras has been modified to split ties, so we'll always go to the cell with the smaller reading order that goes to our target square
        $nextCoord = $cell.Coord
        $map[$unit.Coord.Hash()].Unit = $null
        $map[$nextCoord.Hash()].Unit = $unit
        $unit.Coord = $nextCoord
    }


    # Simulate
    $round = 0
    # print-map
    :sim while ( ($combatants.Team | group).count -eq 2) {
        $round++
        # write-host "Round $round"
        $combatants = $combatants | sort { $_.Coord.row }, { $_.Coord.col } 
        foreach ($combatant in $combatants) {

            if( ($combatants.Team | group).count -ne 2){
                $round--
                break sim
            }

            if ($combatant.Health -le 0) { continue } #Was killed already this round, so skip
        
        
            ## Move
            $orthoCoords = $combatant.Coord.OrthNeighbours()
            $enemysNextTo = $combatants | ? { $_.team -ne $combatant.Team } | ? { $_.Coord -in $orthoCoords }
            if ($enemysNextTo.Count -lt 1) {
                calc-movedirection($combatant)
            }
            ## Attack
            $orthoCoords = $combatant.Coord.OrthNeighbours()
            $enemysNextTo = $combatants | ? { $_.team -ne $combatant.Team } | ? { $_.Coord -in $orthoCoords }
            if ($enemysNextTo.Count -gt 0) {
                $minHealth = ($enemysNextTo.Health | sort)[0]
                $enemyToAttack = ($enemysNextTo | ? Health -EQ $minHealth)[0]
                # write-host "$($combatant.Team) at $($combatant.Coord.Hash()) attacked $($enemyToAttack.Team) at $($enemyToAttack.Coord.Hash())" -ForegroundColor DarkBlue
                $enemyToAttack.Health -= 3
                if ($enemyToAttack.Health -le 0) {
                    # write-host "$($enemyToAttack.Team) died" -ForegroundColor DarkRed
                    $map[$enemyToAttack.Coord.Hash()].Unit = $null
                    $combatants = $combatants | ? { $_ -ne $enemyToAttack }
                }
            }
            # print-map
        }

        #debug
        # 0..($combatants.Count - 1) | % {
        #     write-host "Combatant at $($combatants[$_].Coord.Hash())[$_].Health = $($combatants[$_].Health)"
        # }
        # $z
    }
    write-host "End result"
    print-map
    $total = 0
    $combatants.Health |%{ $total+= $_* $round}
    $total


    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 27730
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" 36334
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

