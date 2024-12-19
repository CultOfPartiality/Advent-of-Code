. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"


function Solution {
    param ($Path)

    # Here we need to find every possible way of making a pattern. To avoid recalcuating (at least within a single pattern)
    # we're keeping track of how many different ways we can make an in progress string. We only work on the longest string,
    # and remove each possible towel. If the new pattern exists, add the amount of ways we can make the current string to 
    # the saved pattern.

    # Future optimisation could include either looking for sub-patterns, and/or keeping the counts between all possible strings

    $data = get-content $Path
    $towels = $data.where({ $_ -eq "" }, "Until") -split ", "
    $patterns = $data.where({ $_ -eq "" }, "SkipUntil") | Select -Skip 1

    $totalPossible = 0
    foreach ($pattern in $patterns) {
        $found = @{}
        :build while($true){
            if($found.count -eq 0){
                $currentString = [PSCustomObject]@{
                    string = $pattern
                    perms = 1
                }
            }
            else{
                $str = $found.values.string | sort {$_.Length} | select -last 1
                $currentString = $found[$str]
                $found.Remove($currentString.string)
            }
            
            foreach ($towel in $towels) {
                if($currentString.string[-1] -ne $towel[-1]){continue} #This is the most important speedup step
                if( (-not $currentString.string.endsWith($towel)) -or $currentString.string.Length -lt $towel.length ){continue}
                $possible = $currentString.string.substring(0,($currentString.string.length-$towel.length))
                if($found.Contains($possible)){
                    $found[$possible].perms += $currentString.perms
                }
                else{
                    $found[$possible] = [PSCustomObject]@{
                        string = $possible
                        perms = $currentString.perms
                    }
                }
            }

            # Check if either we've used up all the possibilities, or we've only got one left and it signifies we're done
            if($found.count -eq 0){ break }
            if ($found.count -eq 1 -and $found.ContainsKey("")) {
                $totalPossible += $found.values[0].perms
                break
            }
        }
    }

    # Output the total ways of making the patterns
    $totalPossible
}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 16
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

