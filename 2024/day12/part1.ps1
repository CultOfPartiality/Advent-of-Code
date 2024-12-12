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
                links  = @()
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
                
                    if (-not $cell.links.Contains($neighbour)) { $cell.links += $neighbour }
                    if (-not $neighbour.links.Contains($cell)) { $neighbour.links += $cell }
                
                    if ($neighbour.inBlob) { continue }
                    $blob += $neighbour
                    $neighbour.inBlob = $true
                    $searchSpace.Enqueue($neighbour)
                }
            }
            $blobs += , $blob
        }
    }

    $total = 0
    foreach ($blob in $blobs) {
        $perimeter = 0
        foreach ($cell in $blob) {
            $perimeter += 4 - $cell.links.count
        }
        # write-host "Blob $($blob[0].value) - Peri: $perimeter, area: $($blob.count)"
        $total += $perimeter * $blob.Count
    }
    $total
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 140
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 1930
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

