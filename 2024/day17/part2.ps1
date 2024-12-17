. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
# $Path = "$PSScriptRoot/testcases/test2.txt"
$Path = "$PSScriptRoot/input.txt"

function Solution {
    param ($Path)


    # My program looks like this:
    #   2,4     bst 4   +-> A % 8 -> B          Load B with 3 LSBs of A
    #   1,1     bxl 1   |   B XOR 1 -> B        Toggle LSB in B
    #   7,5     cdv 5   |   A // (2^B) -> C     A >> (B+1) -> C
    #   0,3     adv 3   |   A // (2^3) -> A     A >> 3 -> A
    #   1,4     bxl 4   |   B XOR 4 -> B        Toggle 3rd bit in B
    #   4,5     bxc 5   |   B XOR C -> B        
    #   5,5     out 5   |   (B % 8) >> out
    #   3,0     jnz 0   +-- A != 0
    
    #Program runs on the lowest three bits of A to generate the output, with some possible meddling
    #from higher bits depending on the value of B
    #So to generate the last number in the program we start with A in [0..7], keep all possible valid
    #values of A, then generate the next program number. Once complete, select the smallest value of A

    $rawData = get-content $Path
    $progString = $rawData[4].trimstart("Program: ")
    $program = $progString -split "," -as [int[]]

    $regs = @{"A" = 0; "B" = 0; "c" = 0 }
    function combo-arg($arg) {
        switch ($arg) {
            { $_ -le 3 } { $arg }
            4 { $regs["A"] }
            5 { $regs["B"] }
            6 { $regs["C"] }
            7 { write-host "Error, combo arg 7" }
            Default {}
        }
    }
    

    function run-program($A,$depth) {
        $instrPtr = 0
        $output = @()
        $regs["A"] = [ulong]$A
        $regs["B"] = $rawData[1].Substring(12) -as [ulong]
        $regs["C"] = $rawData[2].Substring(12) -as [ulong]
        :calc while ($instrPtr -ge 0 -and $instrPtr -lt $program.Count) {
            $op = $program[$instrPtr]
            $arg = $program[$instrPtr + 1]
            $comboArg = combo-arg $arg

            switch ($op) {
                0 { $regs["A"] = [math]::Truncate($regs["A"] / [Math]::Pow(2, $comboArg)) }
                1 { $regs["B"] = $regs["B"] -bxor $arg }
                2 { $regs["B"] = $comboArg % 8 }
                3 { if ($regs["A"] -ne 0) { $instrPtr = $arg - 2 } }
                4 { $regs["B"] = $regs["B"] -bxor $regs["C"] }
                5 {
                    $val = $comboArg % 8
                    $output += $val
                    # We can exit early if the value is not valid, but only if we know what depth
                    # we're expecting
                    if($val -ne $program[ $program.count-$depth+$output.count-1]){
                        break calc
                    }
                }
                6 { $regs["B"] = [math]::Truncate($regs["A"] / [Math]::Pow(2, $comboArg)) }
                7 { $regs["C"] = [math]::Truncate($regs["A"] / [Math]::Pow(2, $comboArg)) }
                Default {}
            }

            $instrPtr += 2
        }
        $output -join ","
    }


    function generate($A, $depth) {
        (run-program $A $depth) -eq ($program[(-$depth)..-1] -join ",")
    }

    [UInt64[]]$validAs = 0..7 | ? { generate $_ 1 }
    2..16 | % {
        $depth = $_
        $validAs = $validAs | % {
            $A = $_ -shl 3
            0..7 | % { $A + $_ } | ? { generate $_ $depth }
        }
    }

    $validAs | sort | select -first 1
}
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
