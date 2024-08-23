. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)


    $dataBlocks = (get-content $Path) -split "\s+" | % { [int]$_ }
    function Hash ($blocks) { $blocks -join "," }
    $distributionCount = 0
    $cache = @{}

    while (-not $cache.ContainsKey((Hash($dataBlocks)))) {
        $cache[(Hash($dataBlocks))] = $distributionCount
        $distributionCount++
        $craneAmount = [int]($dataBlocks | measure -Maximum | select -ExpandProperty Maximum)
        $currentIndex = $dataBlocks.IndexOf($craneAmount)
        $dataBlocks[$currentIndex] = 0
        while ($craneAmount -gt 0) {
            $currentIndex = ($currentIndex + 1) % $dataBlocks.Count
            $dataBlocks[$currentIndex]++
            $craneAmount--
        }
    }
    $distributionCount
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 5
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

