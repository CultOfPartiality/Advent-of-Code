. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test2.txt"

function Solution {
    param ($Path)

    $planets = @{}
    get-content $Path | % {
        $planet, $moon = $_ -split "\)"
        foreach ($body in $planet, $moon) {
            if (!$planets.ContainsKey($body)) {
                $planets[$body] = [PSCustomObject]@{
                    Moons           = @()
                    Orbits          = ''
                    DistanceFromCOM = 0
                }
            }
        }
        $planets[$planet].Moons += @($moon)
        $planets[$moon].Orbits = $planet
    }

    $searchSpace = New-Object 'System.Collections.Generic.PriorityQueue[psobject,int32]'
    $searchSpace.Enqueue('COM', 0)
    while ($searchSpace.Count) {
        $planet = $null
        $orbits = -1
        [void]$searchSpace.TryDequeue([ref]$planet, [ref]$orbits)
        foreach ($moon in $planets[$planet].Moons) {
            $planets[$moon].DistanceFromCOM = $orbits + 1
            $searchSpace.Enqueue($moon, $orbits + 1)
        }
    }

    $transfers = 0
    while ($planets['YOU'].Orbits -ne $planets['SAN'].Orbits) {
        $furthest = $planets['YOU'].DistanceFromCOM -gt $planets['SAN'].DistanceFromCOM ? 'YOU' : 'SAN'
        $planets[$furthest].DistanceFromCOM--
        $planets[$furthest].Orbits = $planets[$planets[$furthest].Orbits].Orbits
        $transfers++
    }
    $transfers

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 4
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

