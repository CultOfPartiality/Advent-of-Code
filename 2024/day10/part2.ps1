. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"


function Solution {
    param ($Path)

    # Part 2 is exactly the same as part one, but instead add the number of ways
    # we reached each 9 to the total. Luckily, since I was already incrementing
    # the hash with each 9, this was just changing what we output.

    # However we can actually remove the hash entirely, and just update the total
    # directly when we find a 9

    $data = get-content $Path
    $width,$height = $data[0].Length , $data.count
    $zeros = @()
    $map = New-Object "int[,]" $height, $width
    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $map[$y, $x] = [int][string]$data[$y][$x]
            if ($data[$y][$x] -eq "0") {
                $zeros += [coords]($y, $x)
            }
        }
    }

    $total = 0
    foreach ($zero in $zeros) {
        $searchSpace = new-object "System.Collections.Queue"
        $searchSpace.Enqueue($zero)

        while ($searchSpace.count) {
            $space = $searchSpace.dequeue()
            foreach ($coord in $space.OrthNeighbours()) {
                if (-not $coord.Contained($height, $width)) { continue }
                if ($map[$coord.array()] -eq ($map[$space.Array()] + 1) ) {
                    if ($map[$coord.array()] -eq 9) {
                        # Only difference, no hash; just add the route to the 
                        # total directly
                        $total++
                    }
                    else {
                        $searchSpace.Enqueue($coord)
                    }
                }
            }
        }
    }

    # Output the total
    $total
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 81
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

