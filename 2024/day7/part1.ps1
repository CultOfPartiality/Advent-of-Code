. "$PSScriptRoot\..\..\Unit-Test.ps1"

function Solution {
	param ($Path)

	# We check the operations in reverse: start with the total, and divide or subtract from the end value until the total is equal to
	# the first value. In this way we can skip ops when the value would be a fraction, or less than the first value. A recursive 
	# function allows us to skip huge swaths of the sample space as needed

	function check-recursive ($total, $remainingValues) {
		# Reducing the total too much, or dividing to a fraction, means we can invalidate this check early
		if($total -lt $remainingValues[0] -or ($total % 1) -gt 0 ){
			return $false
		}
		if($remainingValues.count -eq 1){
			return $total -eq $remainingValues[0]
		}
		else{
			return (check-recursive ($total-$remainingValues[-1]) $remainingValues[0..($remainingValues.count-2)]) -or
				   (check-recursive ($total/$remainingValues[-1]) $remainingValues[0..($remainingValues.count-2)])
		}
	}
	
	get-content $Path  | ForEach-Object {
		[int64]$total, [int64[]]$values = ($_ -replace ":", "" -split " ")

		# Exit early if the min or max value was already valid, or the total would be out of reach
		# This isn't really needed, but does knock maybe 100ms off a 700ms run.
		$min = 0
		$max = 1
		foreach($value in ($values -ne 1)){
			$min+=$value
			$max*=$value
		}
		if($min -eq $total -or $max -eq $total){
			$total
			return
		}
		elseif($min -gt $total -or $max -lt $total){ return }

		if( check-recursive $total $values ){
			$total
		}
	} | measure -sum | select -ExpandProperty Sum
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 3749
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

