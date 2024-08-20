. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

# function Solution {
# 	param ($Path)
$instructions = get-content $Path | % {
    $op, $arg1, $arg2 = $_ -split " "
    switch ($op) {
        "cpy" {
            if ($arg1 -in $registerNames) {
                $op = "cpy"
            }
            else {
                $op = "load"
                $arg1 = [int]$arg1
            }
        }
        "jnz" {
            $arg2 = $arg2
        }
    }
    [PSCustomObject]@{
        op   = $op
        arg1 = $arg1
        arg2 = $arg2
    }
}
$registerNames = ("a", "b", "c", "d")
$registers = @{}
foreach ($regName in $registerNames) {
    $registers[$regName] = 0
}
$aInitValue = 1
$validStateFound = $false
while (-not $validStateFound) {
    # Reset the registes and state cache
    # Set a to the next best starting value
    # Run the simulation until either:
    #   We output something that's not  1 or 0
    #   We output two 1's or two 0's in a row
    #   We see a state that we've seen before
    # If we run into a known state, and the output seen so far is valid (last and first output are different?) then that's our answer
    $lastOutput = $null
    $outputCount = 0
    $cache = @{}
    $pointer = 0
    foreach ($regName in $registerNames) {
        $registers[$regName] = 0
    }
    $registers["a"] = $aInitValue

    :InstructionLoop while ($pointer -lt $instructions.Count) {
        $instruction = $instructions[$pointer]
        switch ($instruction.op) {
            "cpy" {
                $registers[$instruction.arg2] = $registers[$instruction.arg1]
                $pointer++
            }
            "load" {
                $registers[$instruction.arg2] = [int]$instruction.arg1
                $pointer++
            }
            "inc" {
                $registers[$instruction.arg1]++
                $pointer++
            }
            "dec" {
                $registers[$instruction.arg1]--
                $pointer++
            }
            "jnz" {
                $value = ($instruction.arg1 -in $registerNames) ? $registers[$instruction.arg1] : [int]$instruction.arg1
                $jump = ($instruction.arg2 -in $registerNames) ? $registers[$instruction.arg2] : [int]$instruction.arg2
                $pointer += ($value -ne 0) ? $jump : 1
            }
            "out" {
                $outValue = ($instruction.arg1 -in $registerNames) ? $registers[$instruction.arg1] : [int]$instruction.arg1
                # Write-host $outValue
                if ($outValue -notin (0, 1)) {
                    break InstructionLoop
                }
                if ($outValue -eq $lastOutput) {
                    break InstructionLoop
                }
                $lastOutput = $outValue
                $outputCount++
                $pointer++
            }
        }
        # Generate a hash of the game state (register and pointer values), and see if we've seen it before
        $hash = "$pointer,$($registers.a),$($registers.b),$($registers.c),$($registers.d)".GetHashCode()
        if ($cache.ContainsKey($hash) -and $outputCount -ge 3 -and $instruction.op -eq "out" ) {
            # We're in a loop, and have seen at least 01 or 10, so we're on the money
            $validStateFound = $true
            break
        }
        else {
            $cache[$hash] = 1
        }
    }
    # If we made it out, then the sequence doesn't generate forever, so that's no good.
    if (-not $validStateFound) { $aInitValue++ }
    if ($aInitValue % 10 -eq 0) {
        write-host "Up to $aInitValue checked so far"
    }
}
write-host "$aInitValue produces the desired pattern: " -NoNewline

$pointer = 0
$outputCount = 0
foreach ($regName in $registerNames) {
    $registers[$regName] = 0
}
$registers["a"] = $aInitValue

while ($pointer -lt $instructions.Count -and $outputCount -lt 40) {
    $instruction = $instructions[$pointer]
    switch ($instruction.op) {
        "cpy" {
            $registers[$instruction.arg2] = $registers[$instruction.arg1]
            $pointer++
        }
        "load" {
            $registers[$instruction.arg2] = [int]$instruction.arg1
            $pointer++
        }
        "inc" {
            $registers[$instruction.arg1]++
            $pointer++
        }
        "dec" {
            $registers[$instruction.arg1]--
            $pointer++
        }
        "jnz" {
            $value = ($instruction.arg1 -in $registerNames) ? $registers[$instruction.arg1] : [int]$instruction.arg1
            $jump = ($instruction.arg2 -in $registerNames) ? $registers[$instruction.arg2] : [int]$instruction.arg2
            $pointer += ($value -ne 0) ? $jump : 1
        }
        "out" {
            $outValue = ($instruction.arg1 -in $registerNames) ? $registers[$instruction.arg1] : [int]$instruction.arg1
            Write-host $outValue -NoNewline -ForegroundColor DarkGreen
            $outputCount++
            $pointer++
        }
    }
}

# }
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 42
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

