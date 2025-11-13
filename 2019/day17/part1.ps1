. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

# Reused IntCode computer this year
. "$PSScriptRoot\..\IntCodeComputer.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

function Solution {
    param ($Path)

    $ASCII = [Computer]::New(((get-content $Path) -split ',' | % { [int64]$_ }))

    while (!$ASCII.complete) {
        $ASCII.RunComputer($null)
    }

    # Write map
    $ASCII.outputBuffer | % { [char]$_ } | Join-String -Separator "" | write-host

    $map = @(, @())
    $ASCII.outputBuffer | % {
        $val = [char]$_
        if ($_ -eq 10) { $map += , @() }
        else { $map[-1] += $val }
    }

    $width = $map[0].Count
    $height = $map.Count - 2 # Couple of blank lines at the end...?
    $sum = 0
    for ($y = 1; $y -lt ($height - 1); $y++) {
        for ($x = 1; $x -lt ($width - 1); $x++) {
            if ( $map[$y][$x] -eq "#" -and
                $map[$y - 1][$x] -eq "#" -and
                $map[$y + 1][$x] -eq "#" -and
                $map[$y][$x - 1] -eq "#" -and
                $map[$y][$x + 1] -eq "#" 
            ) {
                write-host "Intersection at $x,$y"
                $sum += $x * $y
            }
        }
    }

    $sum

}
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

