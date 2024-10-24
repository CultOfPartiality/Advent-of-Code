. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)
    $polymer = [System.Collections.ArrayList] ((get-content $Path).ToCharArray() | % { [int]$_ })

    # For each possible letter, create a copy of the polymer with that letter removed
    # Check reduced length, and record best
    # The parallel version is a speedup of 8 seconds down to 3 seconds over the normal foreach-object
    
    $polymer | ?{$_ -gt [int][char]'Z'} | select -Unique  | Foreach-Object -ThrottleLimit 16 -Parallel {
        function reduce-polymer($polymer) {
            $keepReacting = $true
            while ($keepReacting) {
                $i = 0
                # If a reaction took place, then we'll do another round
                $keepReacting = $false
                while ($i -lt ($polymer.Count - 1)) {
                    # Convert both chars to ASCII. Two letters with different capitalisation differ by 32
                    $unitASCIIDiff = [math]::ABS($polymer[$i] - $polymer[$i + 1])
                    # Jump the index back one if we did a removal, to speed up the process
                    # If a removal ajoins two more units that can be removed, then lets do that immediately
                    if ($unitASCIIDiff -eq 32) {
                        $polymer.RemoveRange($i, 2)
                        $keepReacting = $true
                        $i = [math]::Max(0, $i - 1)
                    }
                    else { $i++ }
                }
            }
            $polymer.Count
        }
    
        #Action that will run in Parallel. Reference the current object via $PSItem and bring in outside variables with $USING:varname
        $remove = $_,($_-32)
        [System.Collections.ArrayList]$polymerToTest = ($using:polymer).Clone() | ?{$_ -notin $remove}
        $reducedSize = reduce-polymer($polymerToTest)
        $reducedSize
    } | measure -Minimum | select -ExpandProperty Minimum

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 4
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

