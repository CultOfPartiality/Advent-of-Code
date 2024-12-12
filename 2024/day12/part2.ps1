. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)


    $data = get-content $Path

    # Blob detection
    $width, $height = $data[0].Length , $data.count
    $map = New-Object "psobject[,]" $height, $width
    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $map[$y, $x] = [PSCustomObject]@{
                value  = $data[$y][$x]
                coord  = ([coords]($y, $x))
                inBlob = $false
            }
        }
    }

    $blobs = @()
    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            #Find a cell not in a blob. start a new blob. Dijkstras to find joining cells
            $startVal = $map[$y, $x]
            if ($startVal.inBlob) { continue }
            $startVal.inBlob = $true
            $blob = , $startVal

            $searchSpace = New-Object System.Collections.Queue
            $searchSpace.Enqueue($startVal)
            while ($searchSpace.Count) {
                $cell = $searchSpace.Dequeue()
                $validNeighbours = $cell.coord.ValidOrthNeighbours($height,$width) | % { $map[$_.array()] }
                foreach ($neighbour in $validNeighbours) { 
                    if ($neighbour.value -ne $cell.value) { continue }
                    if ($neighbour.inBlob) { continue }
                    $blob += $neighbour
                    $neighbour.inBlob = $true
                    $searchSpace.Enqueue($neighbour)
                }
            }
            $blobs += , $blob
        }
    }

    # Check if a cell has a fence in that direction
    function line-valid($cell,$dir){
        $neighbourCoord = $cell.coord + $dir
        return -not ($neighbourCoord.Contained($height,$width) -and $map[$neighbourCoord.Array()].value -eq $cell.value)
    }
    

    $total = 0
    foreach ($blob in $blobs) {
        $perimeterlines = 0
        # Get all fences to the left of points, and then group by the column
        # For each column, a discontinuity in the sorted row numbers indicates another straight fence
        # Repeat for fences in the other three directions
        foreach($group in $blob | ?{ line-valid $_ (-1,0) } | group {$_.coord.row}){
            #check for discontinuities
            $perimeterlines++
            $cols = $group.group.coord.col | sort
            for ($i = 1; $i -lt $cols.Count; $i++) {
                if($cols[$i] -gt $cols[$i-1]+1){
                    $perimeterlines++
                }
            }
        }
        # check lines below
        foreach($group in $blob | ?{ line-valid $_ (1,0) } | group {$_.coord.row}){
            #check for discontinuities
            $perimeterlines++
            $cols = $group.group.coord.col | sort
            for ($i = 1; $i -lt $cols.Count; $i++) {
                if($cols[$i] -gt $cols[$i-1]+1){
                    $perimeterlines++
                }
            }
        }
        # check lines left
        foreach($group in $blob | ?{ line-valid $_ (0,-1) } | group {$_.coord.col}){
            #check for discontinuities
            $perimeterlines++
            $rows = $group.group.coord.row | sort
            for ($i = 1; $i -lt $rows.Count; $i++) {
                if($rows[$i] -gt $rows[$i-1]+1){
                    $perimeterlines++
                }
            }
        }
        # check lines right
        foreach($group in $blob | ?{ line-valid $_ (0,1) } | group {$_.coord.col}){
            #check for discontinuities
            $perimeterlines++
            $rows = $group.group.coord.row | sort
            for ($i = 1; $i -lt $rows.Count; $i++) {
                if($rows[$i] -gt $rows[$i-1]+1){
                    $perimeterlines++
                }
            }
        }

        $total += $perimeterlines * $blob.Count
    }
    $total
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 80
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 1206
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

