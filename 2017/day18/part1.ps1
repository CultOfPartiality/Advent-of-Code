. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$instructions = get-content $Path | % {
		$op, $x, $y = $_ -split " "
		[PSCustomObject]@{
			Op = $op
			X  = $x
			Y  = $y
		}
	}
	$reg = @{}
	$ptr = 0
	$lastSound = 0
	:loop while ($true) {
		$inst = $instructions[$ptr]
		if ($null -ne $inst.Y) {
			$Y = $reg.ContainsKey($inst.Y) ? $reg[$inst.Y] : [int]$inst.y
		}
		switch ($inst.op) {
			"snd" { $lastSound = $reg[$inst.X] }
			"set" { $reg[$inst.X] = $Y }
			"add" { $reg[$inst.X] += $Y }
			"mul" { $reg[$inst.X] *= $Y }
			"mod" { $reg[$inst.X] %= $Y }
			"jgz" {
				if ($reg[$inst.X] -gt 0) {
					$ptr = $ptr - 1 + $Y # decrement by one, as we always add one to the pointer
				}
			}
			'rcv' {
				if ($inst.X -ne 0) {
					break loop
				}
			}
		}
		$ptr++
	}
	$lastSound

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 4
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

