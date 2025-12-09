. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $data = get-content $Path | % { , [int64[]]($_ -split ",") }
    [Int64]$maxSize = 0

    for ($i = 0; $i -lt $data.Count; $i++) {
        for ($j = $i + 1; $j -lt $data.Count; $j++) {
            $corner1, $corner2 = $data[$i], $data[$j]
            $size = ([Math]::Abs($corner1[0] - $corner2[0]) + 1) * ([Math]::Abs($corner1[1] - $corner2[1]) + 1)
            $maxSize = [Math]::Max($maxSize, $size)
        }
    }
    $maxSize

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 50
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

