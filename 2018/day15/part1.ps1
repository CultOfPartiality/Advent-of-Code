. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/testcases/test2.txt"

#function Solution {
#    param ($Path)


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
        $coord = [Coords]($y,$x)
        $cell = $rawdata[$y][$x]
        # Add to map
        if($cell -ne "#"){
            $mapTile = [PSCustomObject]@{
                Coord = $coord
                Links = @()
                Unit = $null
                dist = $null
                prev = $null
            }
            foreach($delta in (-1,0),(1,0),(0,-1),(0,1) ){
                $neighbourCoord = $coord+$delta
                if($neighbourCoord.Contained($rows,$cols) -and
                    $rawdata[$neighbourCoord.row][$neighbourCoord.col] -ne "#"){
                    $mapTile.Links += $neighbourCoord
                }
            }

            $map[$coord.Hash()] = $mapTile
        }
        else{
            $walls[$coord.Hash()] = $coord
        }
        # Add to combatants
        if($cell -in "G","E"){
            $combatants += [PSCustomObject]@{
                Team = $cell
                Coord = $coord
                Health = 200
            }
            $map[$coord.Hash()].Unit = $combatants[-1]
        }
    }
}
# Change links from coords to objs
foreach($mapTile in $map.Values){
    $mapTile.Links = $map.Values | ?{$_.Coord -in $mapTile.Links}
}

function print-map(){
    write-host "Round $round"
    $printMap = New-Object "char[,]" $rows,$cols
    $map.Values | %{
        $printMap[$_.Coord.Array()] = "."
    }
    $walls.Values | %{
        $printMap[$_.Array()] = "#"
    }
    $combatants | %{
        $printMap[$_.Coord.Array()] = $_.Team
    }

    for ($y = 0; $y -lt $rows; $y++) {
        $rowdata = ""
        for ($x = 0; $x -lt $cols; $x++) {
            $rowdata+=$printMap[$y,$x]
        }
        write-host $rowdata -ForegroundColor DarkGray
    }
}

function dikstras($graph, $startNode) {

    $q = New-Object "System.Collections.Generic.PriorityQueue[psobject,int]"

    $startNode.dist = 0
    $q.Enqueue($startNode, 0)

    while ($q.Count) {
        $u = $q.Dequeue()
        foreach ($v in $u.links) {
            if($v.Unit -ne $null){continue}
            $alt = $u.dist + 1
            if ($v.dist -eq $null -or $alt -lt $v.dist) {
                $v.prev = $u
                $v.dist = $alt
                $q.Enqueue($v, $v.dist) 
            }
        }
    }
}

function calc-movedirection($unit){
    # Need to start at the units location and move out from there
    foreach($mapTile in $map.Values){
        $mapTile.prev = $null
        $mapTile.dist = $null
    }

    dikstras $map $map[$unit.Coord.Hash()] 

    $availableNextToEnemy = $map.Values | ?{$_.dist} | ?{$_.Links.Unit.Team} | ?{$_.Links.Unit.Team -ne $unit.Team} 

    #Now just walk back through the links, find the squares that can be stepped on
    #Break ties, then move
    #update map unit links
    
    $z

    # while($searchQueue.Count){
    #     $loc,$step = $searchQueue.Dequeue()
    #     # Find all neighbours that are valid, and haven't been searched yet
    #     $loc.OrthNeighbours() | ?{-not $coordsSearched.ContainsKey($_.Hash())} | 
    #     ?{ $map[$_.Hash()] -ne $null } | ?{ $_ -notin $combatants.Coords } | %{
    #         $coordsSearched[$_.Hash()] = $step+1
    #         $searchQueue.Enqueue(($_,($step+1)))
    #     }
    # }
    # $z # UP TO HERE. Need to keep track of step direction... Maybe 
}


# Simulate
$round = 0
while( ($combatants.Team | group).count -gt 1){
    $round++
    $combatants = $combatants | sort {$_.Coord.row,$_.Coord.cols}
    foreach($combatant in $combatants){

        if($combatant.Health -le 0){continue} #Was killed already this round, so skip
        
        $orthoCoords = $combatant.Coord.OrthNeighbours()
        
        ## Move
        $enemysNextTo = $combatants | ? {$_.team -ne $combatant.Team} | ?{ $_.Coord -in $orthoCoords}
        if($enemysNextTo.Count -lt 1){
            print-map
            $moveDirection = calc-movedirection($combatant)
            exit
        }
        ## Attack
        $enemysNextTo = $combatants | ? {$_.team -ne $combatant.Team} | ?{ $_.Coord -in $orthoCoords} #sorting not required, as OrthNeighbours is already in reading order
        if($enemysNextTo.Count -gt 0){
            $enemysNextTo[0].Health-=3
            if($enemysNextTo[0].Health -le 0){
                $combatants = $combatants | ?{$_ -ne $enemysNextTo[0]}
            }
        }
    }

    print-map
    $z   
}

$rounds


    
#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

