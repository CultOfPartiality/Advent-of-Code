. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
# $Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/input.txt"

# function Solution {
# 	param ($Path)

$instructions = 0..11 | % { , ("addr", "addi", "mulr", "muli", "banr", "bani", "borr", "bori", "setr", "seti", "gtir", "gtri", "gtrr", "eqir", "eqri", "eqrr") }

$examplesRaw, $programRaw = ((get-content $Path -raw) -split "`r`n`r`n`r`n")
$examples = $examplesRaw -split "`r`n" | Split-Array -GroupSize 4 
$program = $programRaw -split "`r`n"

$examples | % {	 
    [int[]] $beforeRegs = $_[0].TrimStart("Before: [").TrimEnd("]") -split ", "
    $op, $A, $B, $C = $_[1] -split " " | % { [int]$_ }
    [int[]] $afterRegs = $_[2].TrimStart("After: [").TrimEnd("]") -split ", "

    $possibleOps = @()
    if ($beforeRegs[$A] + $beforeRegs[$B] -eq $afterRegs[$C]) { $possibleOps += "addr" }
    if ($beforeRegs[$A] + $B -eq $afterRegs[$C]) { $possibleOps += "addi" }

    if ($beforeRegs[$A] * $beforeRegs[$B] -eq $afterRegs[$C]) { $possibleOps += "mulr" }
    if ($beforeRegs[$A] * $B -eq $afterRegs[$C]) { $possibleOps += "muli" }
	
    if (($beforeRegs[$A] -band $beforeRegs[$B]) -eq $afterRegs[$C]) { $possibleOps += "banr" }
    if (($beforeRegs[$A] -band $B) -eq $afterRegs[$C]) { $possibleOps += "bani" }

    if (($beforeRegs[$A] -bor $beforeRegs[$B]) -eq $afterRegs[$C]) { $possibleOps += "borr" }
    if (($beforeRegs[$A] -bor $B) -eq $afterRegs[$C]) { $possibleOps += "bori" }

    if ($beforeRegs[$A] -eq $afterRegs[$C]) { $possibleOps += "setr" }
    if ($A -eq $afterRegs[$C]) { $possibleOps += "seti" }

    if ($afterRegs[$C] -in 0, 1) {
        if (([int]($A -gt $beforeRegs[$B])) -eq $afterRegs[$C]) { $possibleOps += "gtir" }
        if (([int]($beforeRegs[$A] -gt $B)) -eq $afterRegs[$C]) { $possibleOps += "gtri" }
        if (([int]($beforeRegs[$A] -gt $beforeRegs[$B])) -eq $afterRegs[$C]) { $possibleOps += "gtrr" }
		
        if (([int]($A -gt $beforeRegs[$B])) -eq $afterRegs[$C]) { $possibleOps += "eqir" }
        if (([int]($beforeRegs[$A] -gt $B)) -eq $afterRegs[$C]) { $possibleOps += "eqri" }
        if (([int]($beforeRegs[$A] -gt $beforeRegs[$B])) -eq $afterRegs[$C]) { $possibleOps += "eqrr" }

    }
    if ($instructions[$op].Count -gt 1) {
        $instructions[$op] = $instructions[$op] | ? { $_ -in $possibleOps }
    }
}

# Worked out some instructions, now need to remove those from other possibilities and then run the program


$z
# }
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
