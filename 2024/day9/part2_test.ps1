. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	# This is still a WIP to optimise. Trying bucket the gaps

	$data = (get-content $Path).ToCharArray().ForEach({ [int]([string]$_) })

	$dataReg = $true
	$index = 0
	$id = 0
	$files = [System.Collections.ArrayList]@()
	$files.Capacity = [math]::Ceiling($data.Count / 2)
	$gaps = 0..9 | % { , [System.Collections.ArrayList]@() }
	0..9 | % { $gaps[$_].Capacity = [math]::Ceiling($data.Count / 2) }

	
  
	foreach ($reg in $data) {
		if ($dataReg) {
			if ($reg -ne 0) {
				[void]$files.add([PSCustomObject]@{
						id    = $id
						index = $index
						len   = $reg
					})
			}
			$id++
		}
		else {
			if ($reg -ne 0) {
				[void]$gaps[$reg].add([PSCustomObject]@{
						index = $index
						len   = $reg
					})
			}
		}
		$index += $reg
		$dataReg = -not $dataReg
	}

	for ($i = ($files.Count - 1); $i -ge 0; $i--) {
		$file = $files[$i]
		write-host "Working on file $($file.id)"
		$oldFileIndex = $file.index

		# # Don't split where calls!
		$validGaps = $gaps[$file.len..9].Where({ $_.index -lt $file.index }) | ? { $_ }
		if (-not $validGaps) { continue }
		$validGap = $validGaps[0][0]

		# $gapindex = 0
		# while( $gaps[$gapindex].index -lt $file.index -and $gaps[$gapindex].len -lt $file.len ){$gapindex++} #Hotspot Still
		# $validGap = $gaps[$gapindex]
		# if($validGap.index -gt $file.index -or $validGap.len -lt $file.len){continue}

		$file.index = $validGap.index
		#Make the gap smaller, or "remove it" if not required
		$gaps[$validGap.len].Remove($validGap)
		if ($validGap.len -gt $file.len) {
			$validGap.index += $file.len
			$validGap.len = $validGap.len - $file.len

			[void]$gaps[$validGap.len].add($validGap)
			$gaps[$validGap.len] = [System.Collections.ArrayList]@(  $gaps[$validGap.len] | sort { $_.index } )
		}
	}

	# Calculate the hash and output
	$total = 0
	foreach ($file in $files) {
		for ($i = 0; $i -lt $file.len; $i++) {
			$total += $file.id * ($file.index + $i)
		}
	}
	$total

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 2858
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" 9
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test4.txt" 359
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 1988987902
# Unit-Test  ${function:Solution} "$PSScriptRoot/input.txt" 6469636832766
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

