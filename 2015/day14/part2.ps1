. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
    param ($Path, $totalTime)

    #Get data
    $data = get-content $Path | % {
        $rawdata = ($_ -split " ")[0, 3, 6, 13]
        [PSCustomObject]@{
            name     = $rawdata[0]
            speed    = [int]$rawdata[1]
            onTime   = [int]$rawdata[2]
            offTime  = [int]$rawdata[3]
            period   = [int]$rawdata[2] + [int]$rawdata[3]
            distance = 0
            points   = 0
        }
    }
    
    for ($timeElapsed = 0; $timeElapsed -lt $totalTime; $timeElapsed++) {
        #Move each reindeer
        1..$data.Count | % {
            $reindeer = $data[$_ - 1]
            $timeInPeriod = $timeElapsed % $reindeer.period
            if ($timeInPeriod -lt $reindeer.onTime) {
                $reindeer.distance += $reindeer.speed
            }
        }
        #work out max distance, and increment points
        $maxDist = $data.distance | measure -Maximum | select -ExpandProperty Maximum
        1..$data.Count | % {
            $reindeer = $data[$_ - 1]
            if ($reindeer.distance -eq $maxDist) {
                $reindeer.points++
            }
        }
    }
    #Return result
    $data.points | measure -Maximum |select -ExpandProperty Maximum
}

Unit-Test  ${function:Solution} @("$PSScriptRoot/testcases/test1.txt", 1000) 689
$result = Solution "$PSScriptRoot\input.txt" 2503
Write-Host "Part 2: $result" -ForegroundColor Magenta

