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

    $ferry = [System.Numerics.Vector2]::new(0, 0)

    $waypoint = [System.Numerics.Vector2]::new(10, 1)

    foreach ($inst in $data) {
        switch ($inst.Dir) {
            "N" { $waypoint.y += $inst.Mag }
            "S" { $waypoint.y -= $inst.Mag }
            "E" { $waypoint.x += $inst.Mag }
            "W" { $waypoint.x -= $inst.Mag }
            "L" {
                switch ($inst.Mag) {
                    90 { $waypoint.x, $waypoint.y = - $waypoint.y, $waypoint.x }
                    180 { $waypoint.x, $waypoint.y = - $waypoint.x, - $waypoint.y }
                    270 { $waypoint.x, $waypoint.y = $waypoint.y, - $waypoint.x }
                }
            }
            "R" {
                switch ($inst.Mag) {
                    90 { $waypoint.x, $waypoint.y = $waypoint.y, - $waypoint.x }
                    180 { $waypoint.x, $waypoint.y = - $waypoint.x, - $waypoint.y }
                    270 { $waypoint.x, $waypoint.y = - $waypoint.y, $waypoint.x }
                }
            }
            "F" {
                $ferry += $inst.mag * $waypoint
            }
        }
    }

    [math]::abs($ferry.X) + [math]::abs($ferry.y)

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 286
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
