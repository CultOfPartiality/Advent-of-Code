. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
    param ($Path)

    #The following line is for development
    #$Path = "$PSScriptRoot/testcases/test1.txt"


    #Step 1 - Parse workflows into a hash of objects, parts into array of objects
    $workflowsRaw, $partsRaw = (get-content $Path -Raw) -split "`r`n`r`n"
    $workflowsRaw = $workflowsRaw -split "`r`n"
    $partsRaw = $partsRaw -split "`r`n"
    $workflows = @{}
    foreach ($flow in $workflowsRaw) {
        $parsing = ( $flow | select-string '(?<name>[a-z]*)\{((?<conditions>[a-z]+[<>]\d+:\w+),)+(?<finalDest>\w+)\}' ).Matches.Groups
        $name = $parsing.Where({ $_.Name -eq 'name' }).Value
        $workflow = [PSCustomObject]@{
            Conditions = @()
            FinalDest  = $parsing.Where({ $_.Name -eq 'finalDest' }).Value
        }
    
        $parsing.Where({ $_.Name -eq 'conditions' }).Captures.Value | % {
            $workflow.Conditions += [PSCustomObject]@{
                Category    = $_[0]
                Comparison  = $_[1]
                Threshold   = $_.Substring(2, $_.indexof(":") - 2)
                Destination = $_.Substring($_.indexof(":") + 1)
            }
        }
        $workflows.Add($name, $workflow)
    }
    $parts = foreach ($part in $partsRaw) {
        $elements = $part.Substring(1, $part.Length - 2) -split ","
        [PSCustomObject]@{
            x = [int]$elements[0].Substring(2)
            m = [int]$elements[1].Substring(2)
            a = [int]$elements[2].Substring(2)
            s = [int]$elements[3].Substring(2)
        }
    }

    #Step 2 - For each part, start at 'in' and work through the workflow
    $acceptedParts = foreach ($part in $parts) {
        $dest = 'in'
        while ($dest -notin "R", "A") {
            $workflow = $workflows[$dest]
            foreach ($condition in $workflow.Conditions) {
                $quality = $part."$($condition.Category)"
                if (
                ($quality -gt $condition.Threshold -and $condition.Comparison -eq ">") -or
                ($quality -lt $condition.Threshold -and $condition.Comparison -eq "<")
                ) {
                    $dest = $condition.Destination
                    break
                }
                else {
                    $dest = $workflow.FinalDest
                }
            }
        }
        #only output accepted parts
        if ($dest -eq "A") {
            $part
        }
    }

    $acceptedParts | % { $_.x + $_.m + $_.a + $_.s } | measure -sum | select -ExpandProperty Sum


}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt"  19114
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 1: $result" -ForegroundColor Magenta
