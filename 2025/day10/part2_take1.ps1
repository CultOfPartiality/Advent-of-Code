. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $machines = get-content $Path | % {
        $blocks = $_ -split " "
        $Buttons = $blocks[1..($blocks.Count - 2)] | % {
            #Convert them to toggle masks
            , ($_ -replace "[\(\)]", "" -split "," | % { [int]$_ })
        }
        $Joltages = $blocks[-1] -replace "[\{\}]", "" -split "," | % { [int]$_ }
        [PSCustomObject]@{
            Counters = $Joltages
            Buttons  = $Buttons
        }
    }

    $total = 0
    $line = 0
    foreach ($machine in $machines) {
        # $machine = $machines[0]
        write-host "Working on machine $line"
        $line++
        $totalRequired = $machine.Counters | sum-array
        $state = [PSCustomObject]@{
            Counters       = @(0) * $machine.Counters.Count
            ButtonsPressed = 0
        }
        $minimumPressesRequired = [int32]::MaxValue
        $searchSpace = New-Object "System.Collections.Generic.PriorityQueue[psobject,int]"
        # $searchSpace = New-Object "System.Collections.Generic.Stack[psobject]"
        $searchSpace.Enqueue($state, $totalRequired)
        # $searchSpace.Push($state)
        $statesSeen = @{} #and min buttons to get here
        while ($searchSpace.Count) {
            $state = $searchSpace.Dequeue()
            # $state = $searchSpace.Pop()
            if ($state.ButtonsPressed -gt ($minimumPressesRequired - 1)) { continue }

            foreach ($button in $machine.Buttons ) {
                $newState = [PSCustomObject]@{
                    Counters       = $state.Counters.Clone()
                    ButtonsPressed = $state.ButtonsPressed + 1
                }
                $valid = $true
                foreach ($index in $button) {
                    $newState.Counters[$index]++
                    $valid = $valid -and ($newState.Counters[$index] -le $machine.Counters[$index])
                }
                if (!$valid) { continue }
        
                $FinalStateReached = [Collections.Generic.SortedSet[String]]::CreateSetComparer().Equals($newState.Counters, $machine.Counters)
                if (!$FinalStateReached) {
                    $hash = $newState.Counters -join ","
                    if (!$statesSeen.ContainsKey($hash) -or ($newState.ButtonsPressed -lt $statesSeen[$hash])) {
                        $statesSeen[$hash] = $newState.ButtonsPressed
                        $searchSpace.Enqueue($newState, $totalRequired - ($newState.Counters | sum-array))
                        # $searchSpace.Push($newState)
                    }
                }
                elseif ($newState.ButtonsPressed -lt $minimumPressesRequired) {
                    $minimumPressesRequired = $newState.ButtonsPressed
                    write-host "New minimum button pushes - $minimumPressesRequired"
                }
            }
        }
        $total += $minimumPressesRequired
    }

    $total

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 33
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta