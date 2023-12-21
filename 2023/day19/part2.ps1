. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
    param ($Path)

    #The following line is for development
    # $Path = "$PSScriptRoot/testcases/test1.txt"


    #Step 1 - Parse workflows into a hash of objects, parts into array of objects
    $workflowsRaw, $partsRaw = (get-content $Path -Raw) -split "`r`n`r`n"
    $workflowsRaw = $workflowsRaw -split "`r`n"
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
                Threshold   = [int]$_.Substring(2, $_.indexof(":") - 2)
                Destination = $_.Substring($_.indexof(":") + 1)
            }
        }
        $workflows.Add($name, $workflow)
    }
    $parts = new-object 'System.Collections.Queue'
    $parts.Enqueue(
        [PSCustomObject]@{
            x        = [PSCustomObject]@{min = 1; max = 4000 }
            m        = [PSCustomObject]@{min = 1; max = 4000 }
            a        = [PSCustomObject]@{min = 1; max = 4000 }
            s        = [PSCustomObject]@{min = 1; max = 4000 }
            nextNode = 'in'
        }
    )

    #Step 2 - For each part, start at 'in' and work through the workflow
    #   At each 
    $acceptedParts = @()
    while ($parts.count -gt 0) {
        $part = $parts.Dequeue()
        if ($part.nextNode -eq "A") {
            #add to accepted and remove
            $acceptedParts += $part
            continue
        }
        elseif ($part.nextNode -eq "R") {
            #remove part
            continue
        }
        $workflow = $workflows[$part.nextNode]
        foreach ($condition in $workflow.Conditions) {
            $quality = $part."$($condition.Category)"

            #if any range of the part is valid, add the valid range back to the stack
            if ($condition.Comparison -eq ">" -and
                $quality.max -gt $condition.Threshold) {
                #add a new part to the queue that follows this threshold
                $newPart = [PSCustomObject]@{
                    x        = $part.x.psobject.Copy()
                    m        = $part.m.psobject.Copy()
                    a        = $part.a.psobject.Copy()
                    s        = $part.s.psobject.Copy()
                    nextNode = $condition.Destination
                }
                $newPart."$($condition.Category)".min = [math]::Max($condition.Threshold + 1, $quality.min)
                $parts.Enqueue($newPart)

                #check if the part no longer has any valid ranges, is so end early
                #Otherwise modify the current part to pass through to the next condition
                if ($quality.min -gt $condition.Threshold) {
                    $part = $null
                    break
                }
                $part."$($condition.Category)".max = $condition.Threshold
            }
            elseif ($condition.Comparison -eq "<" -and
                $quality.min -lt $condition.Threshold) {
                #add a new part to the queue that follows this threshold
                $newPart = [PSCustomObject]@{
                    x        = $part.x.psobject.Copy()
                    m        = $part.m.psobject.Copy()
                    a        = $part.a.psobject.Copy()
                    s        = $part.s.psobject.Copy()
                    nextNode = $condition.Destination
                }
                $newPart."$($condition.Category)".max = [math]::Min($condition.Threshold - 1, $quality.max)
                $parts.Enqueue($newPart)

                #check if the part no longer has any valid ranges, is so end early
                #Otherwise modify the current part to pass through to the next condition
                if ($quality.max -lt $condition.Threshold) {
                    $part = $null
                    break
                }
                $part."$($condition.Category)".min = $condition.Threshold
            }
        }
        #check if the part is still valid, and if so send to final dest
        if ($part -ne $null) {
            $part.nextNode = $workflow.FinalDest
            $parts.Enqueue($part)
        }
    }

    $acceptedParts | % {
    ($_.x.max - $_.x.min + 1) * 
    ($_.m.max - $_.m.min + 1) * 
    ($_.a.max - $_.a.min + 1) * 
    ($_.s.max - $_.s.min + 1)
    } | measure -sum | select -ExpandProperty Sum

}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt"  167409079868000
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 2: $result" -ForegroundColor Magenta
