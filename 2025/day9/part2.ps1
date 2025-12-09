. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"


$Path = "$PSScriptRoot/input.txt"
$data = get-content $Path | % { , [int64[]]($_ -split ",") }

# It's like a weird pacman. The best corner to start from will be those inside the mouth, and only looking at those in the same
# semi-circle, and on the opposite side

#Starting point will be index 248 checking against those indexes below, and 249 checking against those above
[int64]$maxSize = 0
$firstIndex = -1
$otherIndex = -1
$corner1 = $data[248]
$MaxY = ($data[0..125] | sort { [math]::abs($_[0] - $corner1[0]) } | select -first 1)[1]

$MaxXSeen = 0
for ($i = 247; $i -gt 125; $i--) {
    $corner2 = $data[$i]
    $size = ([Math]::Abs($corner1[0] - $corner2[0]) + 1) * ([Math]::Abs($corner1[1] - $corner2[1]) + 1)
    #If we've seen an x bigger than this, then it'll overlap with something previous, so skip
    if ($corner2[0] -lt $MaxXSeen) { continue }
    $MaxXSeen = $corner2[0]
    #Y can't get bigger than this, as it's the y on a line above the corner
    if ($corner2[1] -gt $MaxY) { continue }

    if ($size -gt $maxSize) {
        $maxSize = $size
        write-host "New max, index $i"
        $firstIndex = 248
        $otherIndex = $i
    }
}

#Top side
$corner1 = $data[249]
$MaxXSeen = 0
$MinY = ($data[375..($data.count - 1)] | sort { [math]::abs($_[0] - $corner1[0]) } | select -first 1)[1]
for ($i = 250; $i -lt (250 + 250 / 4); $i++) {
    $corner2 = $data[$i]
    $size = ([Math]::Abs($corner1[0] - $corner2[0]) + 1) * ([Math]::Abs($corner1[1] - $corner2[1]) + 1)
    #If we've seen an x bigger than this, then it'll overlap with something previous, so skip
    if ($corner2[0] -lt $MaxXSeen) { continue }
    $MaxXSeen = $corner2[0]
    #Y can't get smaller than this, as it's the y on a line below the corner
    if ($corner2[1] -lt $MinY) { continue }

    if ($size -gt $maxSize) {
        $maxSize = $size
        write-host "New max, index $i"
        $firstIndex = 249
        $otherIndex = $i
    }
}
Write-Host "Part 2: $maxSize" -ForegroundColor Magenta

# Check solution
if($false){exit}

$dataDownscaled = get-content $Path | % { , ( [int64[]]($_ -split ",") | % { [math]::Round($_ / 100) } ) }

[void]([System.Reflection.Assembly]::LoadWithPartialName("System.Drawing"))
$bmp = New-Object System.Drawing.Bitmap(1000, 1000)

# Draw outline
for ($i = 0; $i -lt $dataDownscaled.Count; $i++) {
    $corner1, $corner2 = $dataDownscaled[$i], $dataDownscaled[($i + 1) % $dataDownscaled.Count]
    $xRange = $corner1[0], $corner2[0] | sort
    $yRange = $corner1[1], $corner2[1] | sort
    
    foreach ($x in $xrange[0]..$xRange[1]) {
        foreach ($y in $yrange[0]..$yRange[1]) {
            $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromName("Green"))
        }
    }
    $bmp.SetPixel($corner1[0], $corner1[1], [System.Drawing.Color]::FromName("Red"))
    $bmp.SetPixel($corner2[0], $corner2[1], [System.Drawing.Color]::FromName("Red"))

}

# Draw solution area
$corner1, $corner2 = $dataDownscaled[$firstIndex], $dataDownscaled[$otherIndex]
$xRange = $corner1[0], $corner2[0] | sort
$yRange = $corner1[1], $corner2[1] | sort
foreach ($x in $xrange[0]..$xRange[1]) {
    foreach ($y in $yrange[0]..$yRange[1]) {
        $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromName("Black"))
    }
}
$SavePath = "$PSScriptRoot\test_1000_Part2Solution.bmp"
$bmp.Save($SavePath)
write-host "Solution saved to '$SavePath'"