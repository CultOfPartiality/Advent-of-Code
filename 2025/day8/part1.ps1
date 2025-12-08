. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Params = @{
    Path  = "$PSScriptRoot/testcases/test1.txt"
    Joins = 10
}

function Solution {
    param ($Params)

    $data = get-content $Params.Path | % {
        $x, $y, $z = [int[]]($_ -split ",")
        [PSCustomObject]@{
            x = $x
            y = $y
            z = $z
        }
    }

    $distances = @{}
    for ($i = 0; $i -lt $data.Count; $i++) {
        for ($j = $i + 1; $j -lt $data.Count; $j++) {
            $junc1, $junc2 = $data[$i], $data[$j]
            $distance = [math]::Sqrt(
                [Math]::Pow($junc1.x - $junc2.x, 2) +
                [Math]::Pow($junc1.y - $junc2.y, 2) +
                [Math]::Pow($junc1.z - $junc2.z, 2)
            )
            if (!$distances.ContainsKey($distance)) { $distances[$distance] = @() }
            $distances[$distance] += [PSCustomObject]@{
                j1 = $junc1
                j2 = $junc2
            }
        }
    }

    $subCircuits = [System.Collections.ArrayList]@()
    $sortedDistances = $distances.Keys | sort
    for ($i = 0; $i -lt $Params.Joins; $i++) {
        $distance = $sortedDistances[$i]
        $pair = $distances[$distance]
        #I checked, there are no pairs with the same distance
        $hashset = New-Object "System.Collections.Generic.HashSet[string]"
        [void]$hashset.Add("$($pair.j1.x),$($pair.j1.y),$($pair.j1.z)")
        [void]$hashset.Add("$($pair.j2.x),$($pair.j2.y),$($pair.j2.z)")
        [void]$subCircuits.Add($hashset)
    }

    do {
        $merges = 0
        for ($i = 0; $i -lt $subCircuits.Count; $i++) {
            for ($j = $i + 1; $j -lt $subCircuits.Count; $j++) {
                if ($subCircuits[$i].Overlaps($subCircuits[$j])) {
                    $subCircuits[$i].UnionWith($subCircuits[$j])
                    $subCircuits.RemoveAt($j)
                    $merges++
                }
            }
        }
    }while ($merges -gt 0)

    $subCircuits | % { $_.Count } | sort -Descending | Select-Object -first 3 | Multiply-Array


}
Unit-Test  ${function:Solution} (@{Path = "$PSScriptRoot/testcases/test1.txt"; Joins = 10 }) 40
$measuredTime = measure-command { $result = Solution (@{Path = "$PSScriptRoot\input.txt"; Joins = 1000 }) }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

