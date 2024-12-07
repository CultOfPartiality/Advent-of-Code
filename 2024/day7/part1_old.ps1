. "$PSScriptRoot\..\..\Unit-Test.ps1"

function Solution {
	param ($Path)
	
	# NOTE
	# Keeping this for reference


	# First, work out if this is even possible.
	#	Minimum is to add all entries (unless a number is 1, then multiply)
	#	Maximum is multiply all entries (unless a number is 1, then add)
	# This saves us checking almost 200 entries, as they're already accounted for

	# For each line, work out how many permutations of +'s and *'s there are. Each permuation encodes the operations
	# to execute in binary, where a set bit is * and a cleared bit is +. Run each until we find a perm that works, 
	# then add that total to the calibartion value.

	# Parallelisation here actually doesn't help, 3.5s as opposed to 2.8s

	
	get-content $Path  | ForEach-Object  {
		[int64]$total, [int64[]]$values = ($_ -replace ":", "" -split " ")
		$min = 0
		$max = 1
		foreach($value in ($values -ne 1)){
			$min+=$value
			$max*=$value
		}

		# Exit early if the min or max value was already valid, or the total would be out of reach
		if($min -eq $total -or $max -eq $total){
			$total
			return
		}
		elseif($min -gt $total -or $max -lt $total){ return }
		
		$allPerms = [math]::pow(2, $values.Count - 1)
		:outer for ($perm = 0; $perm -lt $allPerms; $perm++) {
			# Start with the first value already in the total, then loop over the possible operator positions
			# We can also exit early if we go past the total
			$currentTotal = $values[0]
			for ($opPos = 0; $opPos -lt ($values.Count - 1); $opPos++) {
				$currentTotal = ($perm -shr $opPos -band 1) ?
					$currentTotal * $values[$opPos + 1] :
					$currentTotal + $values[$opPos + 1]
				if ($currentTotal -gt $total) { continue outer }
			}
			if ($currentTotal -eq $total) {
				# Output this good total to the pipeline
				$total
				break outer
			}
		}
	} | measure -sum | select -ExpandProperty Sum
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 3749
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

