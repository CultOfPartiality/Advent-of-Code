. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
	param ($Path)

	#The following line is for development
	#$Path = "$PSScriptRoot/testcases/test1.txt"
	# $Path = "$PSScriptRoot/input.txt"

	$data = get-content $Path

	$startingMolecule = $data[-1]
	$transforms = $data[0..($data.count - 3)] | % {
		$regex = $_ | Select-String "(\w*) => (\w*)"
		[PSCustomObject]@{
			val         = $regex.Matches.Groups[1].value
			replacement = $regex.Matches.Groups[2].value
		}
	}

	$resultingMolecules = @()


	$transforms | ForEach-Object {
		$transform = $_
		$finds = Select-String -InputObject $startingMolecule -Pattern $transform.val -AllMatches -CaseSensitive
		if ($finds.Matches.Count -gt 0) {
			$finds.Matches | ForEach-Object {
				$newMolecule = $startingMolecule.Substring(0, $_.Index) + $transform.replacement + $startingMolecule.Substring($_.Index + $_.Length)
				$resultingMolecules+=$newMolecule
			}
		}
	}

	$result = ($resultingMolecules | sort | unique).Count
	$result
	#$resultingMolecules.Count

}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 4
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 7
$result = Solution "$PSScriptRoot\input.txt"
#717, 725, 744, too high
Write-Host "Part 1: $result" -ForegroundColor Magenta


#####Part 2

#Add medicine to the queue, with count of replacements (0)
#Dequeue, and for each possible reverse replacement add to queue, adding 1 to count of replacements
