. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

# function Solution {
# 	param ($Path)

	$registerNames = ("a", "b", "c", "d")
	$registers = @{}
	foreach ($regName in $registerNames) {
		$registers[$regName] = 0
	}
    #For part 1
    $registers["a"] = 7

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

	$pointer = 0
	while ($pointer -lt $instructions.Count) {
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
            "tgl" {
                <# tgl x toggles the instruction x away (pointing at instructions like jnz does: positive means forward; negative means backward):
                    - For one-argument instructions, inc becomes dec, and all other one-argument instructions become inc.
                    - For two-argument instructions, jnz becomes cpy, and all other two-instructions become jnz.
                    - The arguments of a toggled instruction are not affected.
                    - If an attempt is made to toggle an instruction outside the program, nothing happens.
                    - If toggling produces an invalid instruction (like cpy 1 2) and an attempt is later made to execute that instruction, skip it instead.
                    - If tgl toggles itself (for example, if a is 0, tgl a would target itself and become inc a), the resulting instruction is not executed until the next time it is reached.#>
                
                $toggledInstruction = $instructions[$pointer + $registers[$instruction.arg1]]
                $pointer++
                if(-not $toggledInstruction){continue}
                switch($toggledInstruction.op){
                    "tgl" {$toggledInstruction.op = "inc"}
                    "inc" {$toggledInstruction.op = "dec"}
                    "dec" {$toggledInstruction.op = "inc"}
                    "jnz" { $toggledInstruction.op = ($toggledInstruction.arg1 -in $registerNames) ? "cpy" : "load" } 
                    "cpy" {$toggledInstruction.op = "jnz"}
                    "load" {$toggledInstruction.op = "jnz"}
                }

            }
		}
        # $inst_Debug = ($instructions | Format-Table | Out-String) -split "`n"
        # $reg_Debug = ($registers | Format-Table  | Out-String) -split "`n"
        # for($i = 0; $i -lt $inst_Debug.Count; $i++){
		# 	$point = ($i-3) -eq $pointer ? "-->" : "   "
		# 	Write-Host ($point+$inst_Debug[$i])#+$reg_debug[$i])
		# }
		# $z=1
	}
	$registers["a"]
# }
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 42
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

