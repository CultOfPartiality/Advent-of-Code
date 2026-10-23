. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $BaseInstructions = get-content $Path | % {
        $op, $arg = $_ -split " "
        [PSCustomObject]@{
            Op  = $op
            Arg = [int]$arg
            Run = $false
        }
    }

    function Check-Instructions {
        param ($Instructions)
        $acc = 0
        $pc = 0

        while ($true) {
            if ($pc -eq $Instructions.Count) {
                return @($true, $acc)
            }
            $Instruction = $Instructions[$pc]
            if ($Instruction.Run) {
                return @($false, -1)
            }
            switch ($Instruction.Op) {
                'nop' { $pc++ }
                'acc' { $pc++; $acc += $Instruction.Arg }
                'jmp' { $pc += $Instruction.Arg }
            }
            $Instruction.Run = $true
        }
    }

    foreach ($index in 0..($BaseInstructions.Count - 1)) {
        if ($BaseInstructions[$index].Op -ne "acc") {
            $Instructions = $BaseInstructions | % { $_.PSObject.Copy() }
            $Instructions[$index].Op = $Instructions[$index].Op -eq "jmp" ? 'nop' : "jmp"
            $valid, $acc = Check-Instructions $Instructions
            if ($valid) {
                return $acc
            }
        }
    }   
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 8
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
