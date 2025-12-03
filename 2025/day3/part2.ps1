. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $data = get-content $Path
    $total = 0
    foreach ($bank in $data) {
        $BestBats = @()
        $batteries = $bank.ToCharArray() | % { [int]"$_" }
        $lastIndex = -1
        for ($index = 0; $index -lt 12; $index++) {
            $minIndex = $lastIndex + 1
            $maxIndex = $batteries.Count - (12 - $index)
            $remainingBats = $batteries[$minIndex..$maxIndex]
            $BestBats += [int]($remainingBats | Measure-Object -Maximum).Maximum
            $lastIndex = $minIndex + $remainingBats.IndexOf($BestBats[-1])
        }
    
        $bestBatCombo = [int64]($BestBats -join "")
        Write-Host $bestBatCombo
        $total += $bestBatCombo
    }
    $total
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 3121910778619
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta