. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)


	$data = get-content $Path
	$wires = @{}

	$data.where({ $_ -eq "" }, "Until") | % {
		$wire, $value = $_ -split ": "
		$wires[$wire] = $value -eq 1 ? $true : $false
	}

	$gates = $data.where({ $_ -eq "" }, "SkipUntil") | select -Skip 1 | % {
		$a, $op, $b, $q = $_ -split " -> | "
		[PSCustomObject]@{
			A  = $a
			B  = $b
			Op = $op
			Q  = $q
		}
	}

	#naive approach
	while ($gates.count) {
		foreach ($gate in $gates) {
			if ( $wires.ContainsKey($gate.A) -and $wires.ContainsKey($gate.B) ) {
				switch ($gate.Op) {
					"AND" { $wires[$gate.Q] = $wires[$gate.A] -and $wires[$gate.B] }
					"OR" { $wires[$gate.Q] = $wires[$gate.A] -or $wires[$gate.B] }
					"XOR" { $wires[$gate.Q] = $wires[$gate.A] -xor $wires[$gate.B] }
				}
				$gates = $gates | ? { $_ -ne $gate }
			}
		}
	}

	$result = [int64]0
	foreach ($pair in $wires.GetEnumerator()) {
		if ($pair.Key[0] -eq "z" ) {
			$result = $result -bor ([int64]$pair.Value) -shl ([int]$pair.Key.substring(1))
		}
	}

	$result
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 4
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 2024
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

