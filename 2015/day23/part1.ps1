. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
	param ($Path)

	#The following line is for development
	#$Path = "$PSScriptRoot/testcases/test1.txt"
	# $Path = "$PSScriptRoot/input.txt"

	$instructions = get-content $Path | % { [PSCustomObject]@{op = $_.Substring(0, 3); arg1 = $_.Substring(4).split(", ")[0]; arg2 = $_.Substring(4).split(", ")[1] } }

	#Run the "computer"
	$iPointer = 0
	$reg = @{}
	$reg.a = [uint] 0
	$reg.b = [uint] 0
	while ( ($iPointer -ge 0) -and ($iPointer -lt $instructions.Count)) {
		$inst = $instructions[$iPointer]
		$debug = 1
		switch ($inst.op) {
			"hlf" { $reg[$inst.arg1] /= 2; $iPointer++ }
			"tpl" { $reg[$inst.arg1] *= 3; $iPointer++ }
			"inc" { $reg[$inst.arg1] += 1; $iPointer++ }
			"jmp" { $iPointer += [int]$inst.arg1 }
			"jie" { if ($reg[$inst.arg1] % 2 -eq 0) { $iPointer += [int]$inst.arg2 } else { $iPointer++ } }
			"jio" { if ($reg[$inst.arg1] -eq 1) { $iPointer += [int]$inst.arg2 } else { $iPointer++ } }
		}
	}

	$reg.b

}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 0
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/inc.txt" 1
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/tpl.txt" 3
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/hlf.txt" 5
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/jmp.txt" 2
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/jie.txt" 3
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/jio.txt" 3
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 1: $result" -ForegroundColor Magenta

#Not 0

