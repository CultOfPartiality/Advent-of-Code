. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)


	$instructions = get-content $Path

	$registerNames = ("a", "b", "c", "d")
	$registers = @{}
	foreach ($regName in $registerNames) {
		$registers[$regName] = 0
	}

	$pointer = 0
	while ($pointer -lt $instructions.Count) {
		$op, $arg1, $arg2 = $instructions[$pointer] -split " "
		switch ($op) {
			"cpy" {
				if ($arg1 -in $registerNames) {
					$registers[$arg2] = $registers[$arg1]
				}
				else {
					$registers[$arg2] = [int]$arg1
				}
				$pointer++
			}
			"inc" {
				$registers[$arg1]++
				$pointer++
			}
			"dec" {
				$registers[$arg1]--
				$pointer++
			}
			"jnz" {
				if ($registers[$arg1] -ne 0) {
					$pointer += [int]$arg2
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
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

