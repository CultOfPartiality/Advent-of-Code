. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)


    # Loop over data, building up a graph
    $steps = @{}
    get-content $Path | % {
        $precursor = $_[5]
        $nextStep = $_[36]
        if (-not($steps.ContainsKey($precursor))) {
            $steps[$precursor] = [PSCustomObject]@{
                Name       = $precursor
                NextSteps  = [System.Collections.ArrayList]@()
                Precursors = [System.Collections.ArrayList]@()
            }
        }
        if (-not($steps.ContainsKey($nextStep))) {
            $steps[$nextStep] = [PSCustomObject]@{
                Name       = $nextStep
                NextSteps  = [System.Collections.ArrayList]@()
                Precursors = [System.Collections.ArrayList]@()
            }
        }
        $null = $steps[$precursor].NextSteps.Add($steps[$nextStep])
        $null = $steps[$nextStep].Precursors.Add($steps[$precursor])
    }

    $answer = ""
    $stillToGo = $steps.Values
    while ($stillToGo.Count) {
        # remove the first complete (sorted by name)
        $complete = $stillToGo | ? { $_.precursors.count -eq 0 } | sort Name | select -First 1
        $stillToGo = $stillToGo | ? { $_ -ne $complete }
    
        # Add to answer, then remove from precursors of remaining steps
        # Repeat until all complete
        $answer += $complete.Name
        for ($i = 0; $i -lt $stillToGo.Count; $i++) {
            $stillToGo[$i].precursors.Remove($complete)
        }
    }
    $answer
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" "CABDFE"
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

