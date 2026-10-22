. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $map = get-content $Path
    $width = $map[0].length
    $height = $map.count

    function Check-Slope {
        param ($slope)
        $dx, $dy = $slope

        $pos = [PSCustomObject]@{
            x        = 0
            y        = 0
            treesHit = 0
        }

        while ($pos.y -lt $height - 1) {
            $pos.y += $dy
            $pos.x = ($pos.x + $dx) % $width
            $pos.treesHit += $map[$pos.y][$pos.x] -eq "#" ? 1 : 0
        }
        $pos.treesHit
    }

    (1, 1), (3, 1), (5, 1), (7, 1), (1, 2) | % { Check-Slope $_ } | Multiply-Array

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 336
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
