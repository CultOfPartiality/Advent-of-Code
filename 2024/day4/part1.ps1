. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

function Solution {
    param ($Path)

    $data = get-content $Path
    $total = 0
    for ($y = 0; $y -lt $data.Count; $y++) {
        for ($x = 0; $x -lt $data[0].Length; $x++) {
            if ($data[$y][$x] -eq "X") {
                # Once we find an X, we check words in all 8 directions.
                # We use the coords and then a particular delta, adding it once, twice and three times to get the coords of the next chars in the "word"
                # Due to negative indexes looking from the end of the 2D array, and indexes too large throwing an error if not using "[,]" format, check the bounds
                $coord = [Coords]($y, $x)
                foreach ($delta in (0, 1), (0, -1), (1, 0), (-1, 0), (1, 1), (-1, -1), (-1, 1), (1, -1)) {
                    $indexes = ($coord + $delta), ($coord + $delta + $delta), ($coord + $delta + $delta + $delta)
                    if ($indexes.row -lt 0 -or $indexes.row -ge $data.Count) { continue }
                    if ($indexes.col -lt 0 -or $indexes.col -ge $data[0].Length) { continue }
                    # If using a foreach, "-join" is slightly faster than "join-string", but just hard-coding the index offsets drops execution by like 40%
                    # Building the word (for debug mainly) and then comparing is /slightly/ slower, but probably fine.
                    if($data[$indexes[0].row][$indexes[0].col] -eq "M" -and
                       $data[$indexes[1].row][$indexes[1].col] -eq "A" -and
                       $data[$indexes[2].row][$indexes[2].col] -eq "S"){$total++}
                }
            }
        }
    }
    $total

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 18
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

