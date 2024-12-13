. "$PSScriptRoot\..\..\Unit-Test.ps1"

function Solution {
    param ($Path)

    # It's just a set of simultanious equations, so there's only one answer.

    get-content $Path | split-array -groupsize 4 | % {
        [int]$aX, [int]$aY = $_[0].TrimStart("Button A: X") -split ", Y"
        [int]$bX, [int]$bY = $_[1].TrimStart("Button B: X") -split ", Y"
        [int]$prizeX, [int]$prizeY = $_[2].TrimStart("Prize: X=") -split ", Y="
    
        # Sim equations
        #   X = aX1 + bX2
        #   Y = aY1 + bY2

        $bNum = ($aY * $prizeX - $aX * $prizeY) / ($aY * $bX - $aX * $bY)
        $aNum = ($prizeX - $bNum * $bX) / $aX
    
        if ($aNum % 1 -eq 0 -and $bNum % 1 -eq 0) {
            3 * $aNum + $bNum
        }
    } | measure -sum | select -ExpandProperty Sum
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 480
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

