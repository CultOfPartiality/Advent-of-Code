. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    # Not much to say here, just run the interpreter

    $rawData = get-content $Path
    $program = $rawData[4].trimstart("Program: ") -split "," -as [int[]]

    $regs = @{"A" = 0; "B" = 0; "c" = 0 }

    $regs["A"] = $rawData[0].Substring(12) -as [int]
    $regs["B"] = $rawData[1].Substring(12) -as [int]
    $regs["C"] = $rawData[2].Substring(12) -as [int]

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

    $instrPtr = 0
    $output = @()
    while ($instrPtr -ge 0 -and $instrPtr -lt $program.Count) {
        $op = $program[$instrPtr]
        $arg = $program[$instrPtr + 1]
        $comboArg = combo-arg $arg

        switch ($op) {
            0 { $regs["A"] = [math]::Truncate($regs["A"] / [Math]::Pow(2, $comboArg)) }
            1 { $regs["B"] = $regs["B"] -bxor $arg }
            2 { $regs["B"] = $comboArg % 8 }
            3 { if ($regs["A"] -ne 0) { $instrPtr = $arg - 2 } }
            4 { $regs["B"] = $regs["B"] -bxor $regs["C"] }
            5 { $output += $comboArg % 8 }
            6 { $regs["B"] = [math]::Truncate($regs["A"] / [Math]::Pow(2, $comboArg)) }
            7 { $regs["C"] = [math]::Truncate($regs["A"] / [Math]::Pow(2, $comboArg)) }
            Default {}
        }

        $instrPtr += 2
    }

    $output -join ","
   
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" "4,6,3,5,6,3,5,2,1,0"
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

