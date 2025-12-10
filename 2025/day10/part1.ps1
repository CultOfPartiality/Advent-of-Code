. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $machines = get-content $Path | % {
        $blocks = $_ -split " "
        $desiredStateChars = ($blocks[0] -replace "[\[\]]", "").ToCharArray()
        $index = 0
        [int]$desiredState = $desiredStateChars | % {
            $_ -eq "#" ? [Math]::Pow(2, $index) : 0
            $index++
        } | sum-array
        $Buttons = $blocks[1..($blocks.Count - 2)] | % {
            #Convert them to toggle masks
            $_ -replace "[\(\)]", "" -split "," | % { [Math]::Pow(2, [int]$_) } | sum-array
        }
        $Joltages = $blocks[-1]
        [PSCustomObject]@{
            DesiredState = $desiredState
            Buttons      = $Buttons
        }
    }

    $total = 0
    $line = 0
    foreach ($machine in $machines) {
        write-host "Working on machine $line"
        $line++
        $state = [PSCustomObject]@{
            Lamps            = 0
            LastButtonPushed = $null
            ButtonsPressed   = 0
        }
        $minimumPressesRequired = [int32]::MaxValue
        $searchSpace = New-Object "System.Collections.Generic.PriorityQueue[psobject,int]"
        $searchSpace.Enqueue($state, $state.ButtonsPressed)
        $statesSeen = @{} #and min buttons to get here
        while ($searchSpace.Count) {
            $state = $searchSpace.Dequeue()
            if ($state.ButtonsPressed -gt ($minimumPressesRequired - 1)) { continue }

            foreach ($button in ($machine.Buttons | ? { $_ -ne $state.LastButtonPushed }) ) {
                $newState = [PSCustomObject]@{
                    Lamps            = $state.Lamps -bxor $button
                    ButtonsPressed   = $state.ButtonsPressed + 1
                    LastButtonPushed = $button
                }
                if ($newState.Lamps -ne $machine.DesiredState) {
                    if(!$statesSeen.ContainsKey($newState.Lamps) -or ($newState.ButtonsPressed -lt $statesSeen[$newState.Lamps])){
                        $statesSeen[$newState.Lamps] = $newState.ButtonsPressed
                        $searchSpace.Enqueue($newState, $newState.ButtonsPressed)
                    }
                }
                elseif ($newState.ButtonsPressed -lt $minimumPressesRequired) {
                    $minimumPressesRequired = $newState.ButtonsPressed
                    # write-host "New minimum button pushes - $minimumPressesRequired"
                }
            }
        }
        $total += $minimumPressesRequired
    }

    $total



}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 7
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

