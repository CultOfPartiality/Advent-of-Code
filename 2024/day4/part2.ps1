. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $data = get-content $Path

    $total = 0
    for ($y = 0; $y -lt $data.Count; $y++) {
        for ($x = 0; $x -lt $data[0].Length; $x++) {
            if ($data[$y][$x] -eq "A") {
                # Once we find an A, grab all the diagonal letters in order in a circle
                # Due to negative indexes looking from the end of the 2D array, and indexes too large throwing an error if not using
                # "[,]" format, check the bounds and move on if outside
                $A = [Coords]($y, $x)
                $indexes = ($A+(-1, -1)), ($A + (-1, 1)), ($A + (1, 1)), ($A + (1, -1))
                if ($indexes.row -lt 0 -or $indexes.row -ge $data.Count) { continue }
                if ($indexes.col -lt 0 -or $indexes.col -ge $data[0].Length) { continue }
                $chars = $data[$indexes[0].row][$indexes[0].col],
                            $data[$indexes[1].row][$indexes[1].col],
                            $data[$indexes[2].row][$indexes[2].col],
                            $data[$indexes[3].row][$indexes[3].col]
                # Check that we have:
                #   - Two "M"'s
                #   - Two "S"'s
                #   - There's one of either "MM" or "SS" going round the circle (i.e. by making the word), 
                #     indicating we don't have diagonal "SAS" or "MAM"
                if (($chars -eq "M").Count -eq 2 -and ($chars -eq "S").Count -eq 2 -and ($chars -join "") -match "SS|MM"){
                    $total++
                }
            }
        }
    }
    # Output the total number of "X-MAS"'s
    $total
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 9
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

