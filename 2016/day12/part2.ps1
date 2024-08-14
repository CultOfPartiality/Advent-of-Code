. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$registerNames = ("a", "b", "c", "d")
	$registers = @{}
	foreach ($regName in $registerNames) {
		$registers[$regName] = 0
	}
	$registers["c"] = 1

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
				$arg2 = [int]$arg2
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
				$registers[$instruction.arg2] = $instruction.arg1
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
				if ($registers[$instruction.arg1] -ne 0) {
					$pointer += $instruction.arg2
				}
				else {
					$pointer++
				}
			
			}
		}
	}
	$registers["a"]
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 42
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

