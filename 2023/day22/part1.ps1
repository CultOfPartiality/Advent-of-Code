. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
   param ($Path)

#The following line is for development
#$Path = "$PSScriptRoot/testcases/test1.txt"

$data = get-content $Path

$blocks = foreach ($line in $data) {
    $start, $end = $line -split '~' | % { , @($_ -split ',') }
    [PSCustomObject]@{
        x1         = [int]$start[0]
        y1         = [int]$start[1]
        z1         = [int]$start[2]
        x2         = [int]$end[0]
        y2         = [int]$end[1]
        z2         = [int]$end[2]
        landed     = 1 -in ([int]$start[2], [int]$end[2])
        supports   = @()
        supporting = @()
        removeable = $false
    }
}

#measure both, although the blocks are always positive in all axis
$measurex = $blocks.x1 + $blocks.x2 | measure -Minimum -Maximum
$measurey = $blocks.y1 + $blocks.y2 | measure -Minimum -Maximum
$measurez = $blocks.z1 + $blocks.z2 | measure -Minimum -Maximum

#make a grid to hold all "landed" blocks, so we can check below falling blocks
$landed = New-Object 'object[,,]' ($measurex.Maximum + 1), ($measurey.Maximum + 1), ($measurez.Maximum + 1)

function Check-Landed($block) {
    if (1 -in ($block.z1, $block.z2)) {
        return $true
    }
    foreach ($x in $block.x1..$block.x2) {
        foreach ($y in $block.y1..$block.y2) {
            foreach ($z in $block.z1..$block.z2) {
                if ( $null -ne $global:landed[$x, $y, ($z - 1)] -and 
                    $global:landed[$x, $y, ($z - 1)] -ne $block
                ) {
                    return $true
                }
            }
        }
    }
    return $false
}
function Set-Landed($block) {
    foreach ($x in $block.x1..$block.x2) {
        foreach ($y in $block.y1..$block.y2) {
            foreach ($z in $block.z1..$block.z2) {
                $global:landed[$x, $y, $z] = $block
                if ( $global:landed[$x, $y, ($z - 1)] -and 
                    $global:landed[$x, $y, ($z - 1)] -ne $block -and 
                    $global:landed[$x, $y, ($z - 1)] -notin $block.supports
                ) {
                    $block.supports += $global:landed[$x, $y, ($z - 1)]
                    if ($block -notin $global:landed[$x, $y, ($z - 1)].supporting) {
                        $global:landed[$x, $y, ($z - 1)].supporting += $block
                    }
                    
                }
            }
        }
    }
    $block.landed = $true

}

#Set the initial landed blocks in the grid
foreach ($block in $blocks.where{ $_.landed }) {
    Set-Landed $block
}

#loop over all blocks until they've landed
while ( ($blocks.landed -eq $false).Count -gt 0) {
    foreach ($block in $blocks.where{ -not $_.landed }) {
        if (Check-Landed $block) {
            Set-Landed $block
        }
        else {
            $block.z1--
            $block.z2--
        }
    }
}

$clearblocks = foreach ($block in $blocks) {
    $block.removeable = $true
    foreach ($supported in $block.supporting) {
        if ($supported.supports.count -eq 1) {
            $block.removeable = $false
        }
    }
    if ($block.removeable) {
        $block
    }
}

$clearblocks.Count

}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 5
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 1: $result" -ForegroundColor Magenta

