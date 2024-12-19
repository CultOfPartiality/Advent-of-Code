. "$PSScriptRoot\..\..\Unit-Test.ps1"

function Solution {
    param ($Path)

    # We search through each possible way of making the pattern using DFS based on the the length of
    # the in progress string, shortest first. Once a valid pattern is found, we're done for that 
    # pattern.

    # The search starts with the full pattern, and splits on each was we can remove a towel from the
    # end. Once we reach an empty string, we've succeeded in finding a way to make the pattern

    $data = get-content $Path
    $towels = $data.where({ $_ -eq "" }, "Until") -split ", "
    $patterns = $data.where({ $_ -eq "" }, "SkipUntil") | Select -Skip 1

    $totalPossible = 0
    foreach ($pattern in $patterns) {
        $searchSpace = New-Object 'System.Collections.Generic.PriorityQueue[string,int32]'
        $searchSpace.Enqueue($pattern,$pattern.Length)

        :search while ($searchSpace.count) {
            $currentstring = $searchSpace.Dequeue()
            foreach ($towel in $towels) {
                if(-not $currentstring.EndsWith($towel)){continue}
                $possible = $currentString.Substring(0,$currentString.length-$towel.Length)
                if ($possible.Length -eq 0) {
                    $totalPossible++
                    break search
                }
                $searchSpace.Enqueue($possible,$possible.Length)
            }
        }
    }
    $totalPossible
  
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 6
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

