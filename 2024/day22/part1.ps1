. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)


	$data = [int[]] (get-content $Path)


	function nextNum([Int64]$secretNum, $rounds) {

		1..$rounds | % {
			#Step 1
			$secretNum = (($secretNum -shl 6) -bxor $secretNum) % 16777216

			#Step 2
			$secretNum = (($secretNum -shr 5) -bxor $secretNum) % 16777216

			#Step 3
			$secretNum = (($secretNum -shl 11) -bxor $secretNum) % 16777216
		}
	
		#Return
		$secretNum
	}

	$total = 0
	$counter = 0
	foreach ($num in $data) {
		$counter++
		write-host "Working on $counter"
		$num = nextNum $num 2000
		$total += $num
	}

	$total


    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 37327623
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

