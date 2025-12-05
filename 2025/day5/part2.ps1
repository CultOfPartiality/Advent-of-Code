. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$data = get-content $Path | ? { $_.Length -gt 0 }
	$ranges = $data | ? { $_ -match "-" } | % { , @($_ -split "-" | % { [int64]$_ }) }

	function merge-ranges {
		param($a, $b)
		if ($a[0] -ge $b[0] -and $a[0] -le $b[1]) {
			# A   |----|  or     |-| 
			# B |----|    or   |----|   
			return @($b[0], [Math]::Max($a[1], $b[1]))
		}
		elseif ($a[1] -ge $b[0] -and $a[1] -le $b[1]) {
			# A |----|    or   |-| 
			# B    |----| or  |---|
			return @([Math]::Min($a[0], $b[0]), $b[1])
		}
		elseif ($a[0] -le $b[0] -and $a[1] -ge $b[1]) {
			# A |-----|
			# B   |-|
			return $a
		}
		else {
			return
		}
	}
	
	do {
		$merges = 0
		$remainingRanges = $ranges.Clone()
		$ranges = @()
		foreach ($range in $remainingRanges) {
			if ($ranges.Count -eq 0) {
				$ranges += , $range
				continue
			}
			$merged = $false
			for ($i = 0; $i -lt $ranges.Count; $i++) {
				$mergeResult = merge-ranges $range $ranges[$i]
				if ($mergeResult) { 
					$ranges[$i] = $mergeResult
					$merged = $true
					$merges++
					break
				}
			}
			if (!$merged) {
				$ranges += ,$range
			}
		}
	}while($merges -gt 0)
	
	# Add up the valid ids in the merged ranges
	$ranges | %{$_[1]-$_[0]+1} | sum-array
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 14
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

