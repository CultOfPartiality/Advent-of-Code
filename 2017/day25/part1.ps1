. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)


    $startSettings, $stateDescs = (get-content $Path -Raw) -split "\r\n\r\n", 0, "RegexMatch ,Multiline"

    $line1, $line2 = $startSettings -split "\n"
    $cursor = [PSCustomObject]@{
        Position = 0
        State    = ($line1 -split " ")[-1][0]
    }
    $StepsToPerform = [int][string]($line2 -split " ")[-2]
    $tape = @{}
    $states = @{}
    $stateDescs | % {
        $state = @{}
        $lines = $_ -split "\n"
        $state.name = $lines[0][-3]
        $state.options = @(@{}, @{})
        #If current value is 0
        $state.options[0].WriteValue = [int][string]$lines[2][-3]
        $state.options[0].MoveDirection = ($lines[3] -split " ")[-1] -match "left" ? -1 : 1
        $state.options[0].NextState = $lines[4][-3]
        #If current value is 1
        $state.options[1].WriteValue = [int][string]$lines[6][-3]
        $state.options[1].MoveDirection = ($lines[7] -split " ")[-1] -match "left" ? -1 : 1
        $state.options[1].NextState = $lines[8][-2]
        $states[$state.name] = [PSCustomObject]$state
    }
    Write-Host "`nTotal Cycles: $StepsToPerform, Total States: $($states.Count)" -ForegroundColor DarkBlue


    for ($step = 0; $step -lt $StepsToPerform; $step++) {
        if(($step -band 0x7FFFF) -eq 0){
            write-host "$( (100.0*$step/$StepsToPerform).tostring("0.00") )% of cycles performed"
        }

        # Get current tape value (generate it if it doesn't exist)
        $tapeValue = $tape[$cursor.Position] ?? 0
        # Get the operation to perform
        $operation = $states[$cursor.State].options[$tapeValue]
        # Update tape
        $tape[$cursor.Position] = $operation.WriteValue
        # Update cursor
        $cursor.Position += $operation.MoveDirection
        $cursor.State = $operation.NextState
    }

    ($tape.values -eq 1).count

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 3
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

