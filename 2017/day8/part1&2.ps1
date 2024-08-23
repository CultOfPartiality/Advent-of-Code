. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$maxValue = 0
	$instructions = get-content $Path | % {
		$parts = $_ -split " "
		[PSCustomObject]@{
			reg1       = $parts[0]
			delta      = ($parts[1] -eq "inc" ? 1 : -1) * [int]$parts[2]
			reg2       = $parts[4]
			comparison = $parts[5]
			compValue  = [int]$parts[6]
		}
	}
	$reg = @{}

	foreach ($inst in $instructions) {

		if (-not $reg.ContainsKey($inst.reg2)) {
			$reg[$inst.reg2] = 0
		}

		$valid = switch ($inst.comparison) {
			">" { $reg[$inst.reg2] -gt $inst.compValue }
			"<" { $reg[$inst.reg2] -lt $inst.compValue }
			">=" { $reg[$inst.reg2] -ge $inst.compValue }
			"<=" { $reg[$inst.reg2] -le $inst.compValue }
			"!=" { $reg[$inst.reg2] -ne $inst.compValue }
			"==" { $reg[$inst.reg2] -eq $inst.compValue }
		}
		if ($valid) {
			$reg[$inst.reg1] += $inst.delta
			$maxValue = [math]::Max($reg[$inst.reg1],$maxValue)
		}
	}

	"$($reg.Values | measure -Maximum | select -ExpandProperty Maximum), $maxValue"
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" "1, 10"
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1, Part2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

