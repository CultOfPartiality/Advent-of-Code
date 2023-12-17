. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
    param ($Path,$totalTime)

    #Get data
    $data = get-content $Path | % {
        $rawdata = ($_ -split " ")[0, 3, 6, 13]
        [PSCustomObject]@{
            name    = $rawdata[0]
            speed   = [int]$rawdata[1]
            onTime  = [int]$rawdata[2]
            offTime = [int]$rawdata[3]
            period  = [int]$rawdata[2] + [int]$rawdata[3]
        }
    }

    $data | % {
        $reindeer = $_
        $fullPeriods = [math]::floor($totalTime / $reindeer.period)
        $remainingTime = $totalTime - $fullPeriods * $reindeer.period
    
        $totalDistance = $reindeer.speed * ($fullPeriods * $reindeer.onTime + [math]::min($remainingTime, $reindeer.onTime))
        $totalDistance
    } | measure -Maximum | select -ExpandProperty Maximum

    
}

Unit-Test  ${function:Solution} @("$PSScriptRoot/testcases/test1.txt",1000) 1120
$result = Solution "$PSScriptRoot\input.txt" 2503
Write-Host "Part 1: $result" -ForegroundColor Magenta

