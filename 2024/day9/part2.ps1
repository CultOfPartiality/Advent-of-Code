. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	# To optimise moving the files, we keep track of the gaps of each size in a priority queue
    # Then for each move, check all the queues of at least that size for the first available 
    # gap of the right size

	$data = (get-content $Path).ToCharArray().ForEach({ [int]([string]$_) })

	$dataReg = $true
	$index = 0
	$id = 0
	$files = [System.Collections.ArrayList]@()
	$files.Capacity = [math]::Ceiling($data.Count / 2)
	$gaps = 0..9 | % { , (new-object "System.Collections.Generic.PriorityQueue[psobject,int]") }
  
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
				$gaps[$reg].Enqueue(
					[PSCustomObject]@{
						index = $index
						len   = $reg
					},$index)
			}
		}
		$index += $reg
		$dataReg = -not $dataReg
	}

	for ($i = ($files.Count - 1); $i -ge 0; $i--) {
		$file = $files[$i]

		# Check the first gap in each bucket of adequate size and valid index, sorted by lowest index
		$possibleGaps = foreach($gapLen in $file.len..9){
			if($gaps[$gapLen].Count){
				$gap = $gaps[$gapLen].Peek()
				if($gap.index -lt $file.index){
					$gap
				}
			}
		}
		if ($possibleGaps.count -lt 1) { continue }
		$gap = ($possibleGaps | sort {$_.index})[0]
		$validGap = $gaps[$gap.len].Dequeue()

		$file.index = $validGap.index
		#Make the gap smaller, or "remove it" if not required
		if ($validGap.len -gt $file.len) {
			$validGap.index += $file.len
			$validGap.len = $validGap.len - $file.len
			$gaps[$validGap.len].Enqueue($validGap,$validGap.index)
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
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 1988987902
Unit-Test  ${function:Solution} "$PSScriptRoot/input.txt" 6469636832766
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

