. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $data = get-content $Path
    $width = $data[0].length
    $height = $data.count

    $data = $data | % { ".$_." }
    $data = @(@(".") * ($width + 2) -join "") + $data + @(@(".") * ($width + 2) -join "")

    $totalValid = 0
    for ($x = 1; $x -lt ($width + 1); $x++) {
        for ($y = 1; $y -lt ($height + 1); $y++) {
            if ($data[$y][$x] -eq ".") { continue }
            $totalSurrounding = -1
            foreach ($vert in $data[($y - 1)..($y + 1)]) {
                foreach ($char in $vert[($x - 1)..($x + 1)]) {
                    if ($char -eq "@") { $totalSurrounding++ }
                }
            }
            if ($totalSurrounding -lt 4) { $totalValid++ }
        }
    }
    $totalValid    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 13
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

