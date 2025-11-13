. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

# Reused IntCode computer this year
. "$PSScriptRoot\..\IntCodeComputer.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

# function Solution {
#     param ($Path)

$ASCII = [Computer]::New(((get-content $Path) -split ',' | % { [int64]$_ }))

while (!$ASCII.complete) {
    $ASCII.RunComputer($null)
}

# Write map
# $ASCII.outputBuffer | % { [char]$_ } | Join-String -Separator "" | write-host

$robot = [PSCustomObject]@{
    dir = 0 # 0-3: Up,Right,Down,Left
    x   = 0
    y   = 0
}
$initialDir = @{"^" = 0; ">" = 1; "v" = 2; "<" = 3 }
$dirDiffToTurn = @{-1="L";1="R"}

$map = @(, @())
$ASCII.outputBuffer | % {
    $val = [char]$_
    if ($_ -eq 10) { $map += , @() }
    else { $map[-1] += $val }
    if ($val -in "<", ">", "v", "^") {
        $robot.dir = $initialDir["$val"]
        $robot.y = $map.count - 1
        $robot.X = $map[-1].count - 1
    }
}
$width = $map[0].Count
$height = $map.Count - 2 # Couple of blank lines at the end...?

$RawPath = @()

# Work out initial turn to align with scaffold.
#   Based on the problem, this will always be straight, left, or right
$turn = 0
$turn = switch ("#") {
    ($map[$robot.y][$robot.x+1]) { [math]::Sign(1 - $robot.dir) }
    ($map[$robot.y][$robot.x-1]) { [math]::Sign(($robot.dir-1) % 2) }
    ($map[$robot.y+1][$robot.x]) { [math]::Sign(2 - $robot.dir) }
    ($map[$robot.y-1][$robot.x]) { [math]::Sign(($robot.dir-2) % 2) }
}
if($turn -ne 0){
    $RawPath += $turn -eq 1 ? "R" : "L"
    $robot.dir = ($robot.dir + 4 + $turn) % 4
}

# Walk the scaffold, only turning when you have to (i.e. go straight through intersections)

# Spit out the directions for now for me to look at



# }
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

