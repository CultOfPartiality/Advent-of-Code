. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$data = get-content $Path | ? { $_.Length -gt 0 }
	[System.Collections.ArrayList]$ranges = $data | ? { $_ -match "-" } | % { , @($_ -split "-" | % { [int64]$_ }) }

	function check-overlap{
		param($a, $b)
		return (
			($a[0] -ge $b[0] -and $a[0] -le $b[1]) -or 
			# A   |----|  or     |-| 
			# B |----|    or   |----|   
			($a[1] -ge $b[0] -and $a[1] -le $b[1]) -or
			# A |----|    or   |-| 
			# B    |----| or  |---|
			($a[0] -le $b[0] -and $a[1] -ge $b[1])
			# A |--------|
			# B    |--|
		)
	}

	do {
		$merges = 0
		for ($i = 0; $i -lt $ranges.Count; $i++) {
			for ($j = $i+1; $j -lt $ranges.Count; $j++) {
				$r1,$r2 = $ranges[$i,$j]
				if(check-overlap $r1 $r2){
					$ranges[$i] = @([Math]::Min($r1[0], $r2[0]), [Math]::Max($r1[1], $r2[1]))
					$ranges.RemoveAt($j)
					$merges++
				}
			}
		}
	}while($merges -gt 0)
	
	# Add up the valid ids in the merged ranges
	$ranges | %{$_[1]-$_[0]+1} | sum-array
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 14
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

