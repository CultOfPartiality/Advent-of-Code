. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
    param ($Path)

    # Same as part 1, but with a bigger prize

    $res = get-content $Path | split-array -groupsize 4 | % {
        [int64]$aX, [int64]$aY = $_[0].TrimStart("Button A: X") -split ", Y"
        [int64]$bX, [int64]$bY = $_[1].TrimStart("Button B: X") -split ", Y"
        [int64]$prizeX, [int64]$prizeY = $_[2].TrimStart("Prize: X=") -split ", Y="
        $prizeX += 10000000000000
        $prizeY += 10000000000000
    
        $bNum = ($aY * $prizeX - $aX * $prizeY) / ($aY * $bX - $aX * $bY)
        $aNum = ($prizeX - $bNum * $bX) / $aX
    
        if (
            $aNum % 1 -eq 0 -and
            $bNum % 1 -eq 0
        ) {3 * $aNum + $bNum}
    } | measure -sum | select -ExpandProperty Sum

    # Required to avoid scientific notation
    $res.ToString()
}
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
