. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test2.txt"

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
	$programs = 0..1 | % {
		[PSCustomObject]@{
			ID         = $_
			reg        = @{p = $_ }
			ptr        = 0
			lastSound  = 0
			queue      = [System.Collections.ArrayList]@()
			waiting    = $false
			terminated = $false
			sendCount  = 0
		}
	}

	function Execute-Program {
		param($programs, $index)

		$program = $programs[$index]
		if ($program.terminated) { return }
		if ($program.ptr -ge $instructions.Count) {
			$program.terminated = $true
		}
		$inst = $instructions[$program.ptr]
		if ($null -ne $inst.Y) {
			$Y = $program.reg.ContainsKey($inst.Y) ? $program.reg[$inst.Y] : [int]$inst.y
		}
		switch ($inst.op) {
			"set" { $program.reg[$inst.X] = $Y }
			"add" { $program.reg[$inst.X] += $Y }
			"mul" { $program.reg[$inst.X] *= $Y }
			"mod" { $program.reg[$inst.X] %= $Y }
			"jgz" { $program.ptr = ($program.reg[$inst.X] -gt 0) ? $program.ptr - 1 + $Y  : $program.ptr }# decrement by one, as we always add one to the pointer

			"snd" {
				$program.sendCount++
				$null = $programs[$index -bxor 1].queue.add($program.reg[$inst.X])
			}

			'rcv' {
				if ($program.queue.count -gt 0) {
					$program.reg[$inst.X] = $program.queue[0]
					$program.queue.RemoveAt(0)
					$program.waiting = $false
				}
				else {
					$program.ptr--
					$program.waiting = $true
				}
			}
		}
		$program.ptr++
	}


	:loop while ($true) {
		Execute-Program $programs 0
		Execute-Program $programs 1
		if (
		($programs[0].waiting -or $programs[0].terminated) -and 
		($programs[1].waiting -or $programs[1].terminated)) {
			break loop
		}
	}
	$programs[1].sendCount

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 3
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

