. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $planets = @{}
    get-content $Path | % {
        $planet, $moon = $_ -split "\)"
        $planets[$planet] += @($moon)
    }

    $searchSpace = New-Object 'System.Collections.Generic.PriorityQueue[psobject,int32]'
    $totalOrbits = 0
    $searchSpace.Enqueue('COM', 0)
    while ($searchSpace.Count) {
        $planet = $null
        $orbits = -1
        [void]$searchSpace.TryDequeue([ref]$planet, [ref]$orbits)
        $orbiters = $planets[$planet]
        $orbits += 1
        foreach ($orbiter in $orbiters) {
            $totalOrbits += $orbits
            $searchSpace.Enqueue($orbiter, $orbits)
        }
    }
    $totalOrbits
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 42
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

