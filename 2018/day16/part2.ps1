. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
    param ($Path)

    $instructions = 0..15 | % { , @() }

    $examplesRaw, $programRaw = ((get-content $Path -raw) -split "`r`n`r`n`r`n`r`n")
    $examples = $examplesRaw -split "`r`n" | Split-Array -GroupSize 4 
    $program = $programRaw -split "`r`n"

    $examples | Sort-Object { [int]($_[1] -split " ")[0] } | % {	 
        [int[]] $beforeRegs = $_[0].TrimStart("Before: [").TrimEnd("]") -split ", "
        $op, $A, $B, $C = $_[1] -split " " | % { [int]$_ }
        [int[]] $afterRegs = $_[2].TrimStart("After: [").TrimEnd("]") -split ", "

        $possibleOps = @()
        if ( ($beforeRegs[$A] + $beforeRegs[$B]) -eq $afterRegs[$C]) { $possibleOps += "addr" }
        if ( ($beforeRegs[$A] + $B) -eq $afterRegs[$C]) { $possibleOps += "addi" }

        if ( ($beforeRegs[$A] * $beforeRegs[$B]) -eq $afterRegs[$C]) { $possibleOps += "mulr" }
        if ( ($beforeRegs[$A] * $B) -eq $afterRegs[$C]) { $possibleOps += "muli" }
	
        if ( ($beforeRegs[$A] -band $beforeRegs[$B]) -eq $afterRegs[$C]) { $possibleOps += "banr" }
        if ( ($beforeRegs[$A] -band $B) -eq $afterRegs[$C]) { $possibleOps += "bani" }

        if ( ($beforeRegs[$A] -bor $beforeRegs[$B]) -eq $afterRegs[$C]) { $possibleOps += "borr" }
        if ( ($beforeRegs[$A] -bor $B) -eq $afterRegs[$C]) { $possibleOps += "bori" }

        if ( $beforeRegs[$A] -eq $afterRegs[$C]) { $possibleOps += "setr" }
        if ( $A -eq $afterRegs[$C]) { $possibleOps += "seti" }

        if ($afterRegs[$C] -in 0, 1) {
            if (([int]($A -gt $beforeRegs[$B])) -eq $afterRegs[$C]) { $possibleOps += "gtir" }
            if (([int]($beforeRegs[$A] -gt $B)) -eq $afterRegs[$C]) { $possibleOps += "gtri" }
            if (([int]($beforeRegs[$A] -gt $beforeRegs[$B])) -eq $afterRegs[$C]) { $possibleOps += "gtrr" }
		
            if (([int]($A -eq $beforeRegs[$B])) -eq $afterRegs[$C]) { $possibleOps += "eqir" }
            if (([int]($beforeRegs[$A] -eq $B)) -eq $afterRegs[$C]) { $possibleOps += "eqri" }
            if (([int]($beforeRegs[$A] -eq $beforeRegs[$B])) -eq $afterRegs[$C]) { $possibleOps += "eqrr" }
        }

        if ($instructions[$op].Count -eq 0) {
            $instructions[$op] = $possibleOps
        }
        else {
            $instructions[$op] = $instructions[$op] | ? { $_ -in $possibleOps }
        }
    }

    # Worked out some instructions, now need to remove those from other possibilities and then run the program
    # Write-Host "Initial options:"
    # $z = 0; $instructions | % { write-host ("$z - " + ($_ -join ",")); $z++ }
    while ( ($instructions | % { $_.count }) -gt 1 ) {
        $foundInsts = $instructions | ? { $_.count -eq 1 } 
        for ($i = 0; $i -lt $instructions.Count; $i++) {
            if ($instructions[$i].count -gt 1) {
                $instructions[$i] = $instructions[$i] | ? { $_ -notin $foundInsts }
            }
        }
    }
    # Write-Host "`nFinal Op Codes:"
    # $z = 0; $instructions | % { write-host ("$z - " + ($_ -join ",")); $z++ }

    # Run Program
    $Regs = 0, 0, 0, 0

    foreach ($instr in $program) {
        $opNum, $A, $B, $C = $instr -split " " | % { [int]$_ }
        $opCode = $instructions[$opNum]
        $Regs[$C] = switch ($opCode) {
            'addr' { $Regs[$A] + $Regs[$B] }
            'addi' { $Regs[$A] + $B }
            'mulr' { $Regs[$A] * $Regs[$B] }
            'muli' { $Regs[$A] * $B }
            'banr' { $Regs[$A] -band $Regs[$B] }
            'bani' { $Regs[$A] -band $B }
            'borr' { $Regs[$A] -bor $Regs[$B] }
            'bori' { $Regs[$A] -bor $B }
            'setr' { $Regs[$A] }
            'seti' { $A }
            'gtir' { [int] ( $A -gt $Regs[$B] ) }
            'gtri' { [int] ( $Regs[$A] -gt $B ) }
            'gtrr' { [int] ( $Regs[$A] -gt $Regs[$B] ) }
            'eqir' { [int] ( $A -eq $Regs[$B] ) }
            'eqri' { [int] ( $Regs[$A] -eq $B ) }
            'eqrr' { [int] ( $Regs[$A] -eq $Regs[$B] ) }
            Default { Write-host "Error!"; Exit }
        }
    }

    #Answer
    $Regs[0]
}
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
