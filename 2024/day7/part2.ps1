. "$PSScriptRoot\..\..\Unit-Test.ps1"
function Solution {
	param ($Path)

	# Same as part 1, except with the concat operation. Getting this working as a "remove" was a bear, as the ".TrimEnd" function
	# acts as list of chars to remove. So triming "18" from "818" results in nothing...

	get-content $Path | Foreach-Object {
		$line = $_
		[int64]$total, [int64[]]$values = ($line -replace ":", "" -split " ")

		function check-recursive($total, $remainingValues) {
			# Reducing the total too much, or dividing to a fraction, means we can invalidate this check early
			if ($total -lt $remainingValues[0] -or ($total % 1) -gt 0 ) { return $false }

			# Once we're down to the final value, it should equal the total we've made
			if ($remainingValues.count -eq 1) { return ($total -eq $remainingValues[0]) }
	
			# Otherwise, perform the other checks
			if(check-recursive ($total - $remainingValues[-1]) $remainingValues[0..($remainingValues.count - 2)]) {return $true}
			if(check-recursive ($total / $remainingValues[-1]) $remainingValues[0..($remainingValues.count - 2)]) {return $true}
				
			if(([string]$total).EndsWith([string]$remainingValues[-1])){
				$strTotal = [string]$total
				$strValue = [string]$remainingValues[-1]
				$total = [int64]$strTotal.Substring(0,$strTotal.Length - $strValue.Length)
				return (check-recursive $total $remainingValues[0..($remainingValues.count - 2)]) 
			}
			return $false
		}

		if ( (check-recursive $total $values) ) {
			return $total
		}
	} | measure -sum | select -ExpandProperty Sum
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 11387
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 1274
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

