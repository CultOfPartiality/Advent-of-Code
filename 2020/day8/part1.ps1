. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $Instructions = get-content $Path | % {
        $op, $arg = $_ -split " "
        [PSCustomObject]@{
            Op  = $op
            Arg = [int]$arg
            Run = $false
        }
    }

    $acc = 0
    $pc = 0

    while ($true) {
        $Instruction = $Instructions[$pc]
        if ($Instruction.Run) {
            break
        }
        switch ($Instruction.Op) {
            'nop' { $pc++ }
            'acc' { $pc++; $acc += $Instruction.Arg }
            'jmp' { $pc += $Instruction.Arg }
        }
        $Instruction.Run = $true
    }
    $acc
   
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 5
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

