. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $map = get-content $Path
    $width = $map[0].length
    $height = $map.count

    $pos = [PSCustomObject]@{
        x        = 0
        y        = 0
        treesHit = 0
    }

    while ($pos.y -lt $height - 1) {
        $pos.y++
        $pos.x = ($pos.x + 3) % $width
        $pos.treesHit += $map[$pos.y][$pos.x] -eq "#" ? 1 : 0
    }

    $pos.treesHit
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 7
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

