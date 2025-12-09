. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/input.txt"

$data = get-content $Path | % { , ( [int64[]]($_ -split ",")| %{[math]::Round($_/10)} )}
[Int64]$maxSize = 0

[void]([System.Reflection.Assembly]::LoadWithPartialName("System.Drawing"))
$bmp = New-Object System.Drawing.Bitmap(10000, 10000)
    
for ($i = 0; $i -lt $data.Count; $i++) {
    $corner1, $corner2 = $data[$i], $data[($i + 1) % $data.Count]
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

$bmp.Save("$PSScriptRoot\test_10000.bmp")
