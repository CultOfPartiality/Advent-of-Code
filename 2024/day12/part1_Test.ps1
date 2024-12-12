. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    # Same as part 1, except only keeping track of perimeters


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

    $total = 0
    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            #Find a cell not in a blob. start a new blob. Dijkstras to find joining cells
            $startVal = $map[$y, $x]
            if ($startVal.inBlob) { continue }
            $blobPeri = 0
            $blobArea = 0

            $searchSpace = New-Object System.Collections.Queue
            $searchSpace.Enqueue($startVal)
            while ($searchSpace.Count) {
                $cell = $searchSpace.Dequeue()
                if($cell.inBlob){continue}
                $cell.inBlob=$true
                $validNeighbours = $cell.coord.OrthNeighbours().Where({ $_.Contained($height, $width) -and $map[$_.Array()].value -eq $cell.value}) | % { $map[$_.array()] }
                $blobPeri+= 4 - $validNeighbours.Count
                $blobArea++
                foreach ($neighbour in $validNeighbours) { 
                    if ($neighbour.inBlob) { continue }
                    $searchSpace.Enqueue($neighbour)
                }
            }
            $total += $blobPeri * $blobArea
        }
    }

    $total
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 140
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 1930
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

