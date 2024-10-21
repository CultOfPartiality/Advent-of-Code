. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test2.txt"

function Solution {
	param ($Path)

	function compare-strings{
		param (
			$string1,
			$string2
		)
		$returnVal = [PSCustomObject]@{
			DiffCount = 0
			DiffIndex = 0
		}
		for ($i = 0; $i -lt $string1.Length; $i++) {
			if($string1[$i] -ne $string2[$i]){
				$returnVal.DiffCount++
				$returnVal.DiffIndex = $i
			}
			if($returnVal.DiffCount -gt 1){break}
		}

		return $returnVal
	}
	
	$data = get-content $Path

	:outer for ($id_1 = 0; $id_1 -lt $data.Count; $id_1++) {
		for ($id_2 = $id_1 + 1; $id_2 -lt $data.Count; $id_2++) {
			$comp = compare-strings $data[$id_1] $data[$id_2]
			if ( $comp.DiffCount -eq 1) {
				break outer
			}
		}
	}

	$string = [System.Collections.ArrayList] ($data[$id_1].ToCharArray())
	$string.RemoveAt($comp.DiffIndex)
	$string -join ""


}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" "fgij"
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
