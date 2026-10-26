. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $data = get-content $Path | % {
        [PSCustomObject]@{
            Dir = $_[0]
            Mag = [int]$_.Substring(1)
        }
    }

    $ferry = [PSCustomObject]@{
        dir = 90 #Degrees, so 90 is East. 0=North, clockwise is +ve
        x   = 0 #East is +ve
        y   = 0 #North is +ve
    }

    foreach ($inst in $data) {
        switch ($inst.Dir) {
            "N" { $ferry.y += $inst.Mag }
            "S" { $ferry.y -= $inst.Mag }
            "E" { $ferry.x += $inst.Mag }
            "W" { $ferry.x -= $inst.Mag }
            "L" { $ferry.dir = (360 + $ferry.dir - $inst.mag) % 360 }
            "R" { $ferry.dir = ($ferry.dir + $inst.mag) % 360 }
            "F" {
                switch ($ferry.dir) {
                    0 { $ferry.y += $inst.Mag }
                    90 { $ferry.x += $inst.Mag }
                    180 { $ferry.y -= $inst.Mag }
                    270 { $ferry.x -= $inst.Mag }
                }
            }
        }
    }

    [math]::Abs($ferry.x) + [math]::abs($ferry.y)

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 25
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

