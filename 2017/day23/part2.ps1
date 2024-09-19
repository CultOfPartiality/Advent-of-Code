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
	"a".."h" | %{ $reg[[string]$_] = 0 }
	$reg[[string]"a"] = 1
	$ptr = 0
	$muls = 0
	while ($ptr -ge 0 -and $ptr -lt $instructions.count) {
		$inst = $instructions[$ptr]
		$Y = $reg.ContainsKey($inst.Y) ? $reg[$inst.Y] : [int]$inst.y
		$X = $reg.ContainsKey($inst.X) ? $reg[$inst.X] : [int]$inst.x
		switch ($inst.op) {
			"set" { $reg[$inst.X] = $Y }
			"sub" { $reg[$inst.X] -= $Y }
			"mul" { $reg[$inst.X] *= $Y ; $muls++}
			"jnz" {
				if ($X -ne 0) {
					$ptr = $ptr - 1 + $Y # decrement by one, as we always add one to the pointer
				}
			}
		}
		$ptr++
	}
	$reg[[string]"h"]
}
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 4
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
