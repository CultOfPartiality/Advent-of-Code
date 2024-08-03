. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
	param ($Path)

	#The following line is for development
	# $Path = "$PSScriptRoot/testcases/part2_test1.txt"
	# $Path = "$PSScriptRoot/input.txt"

	$data = get-content $Path

	$startingMolecule = $data[-1]
	$transforms = $data[0..($data.count - 3)] | sort -Descending | % {
		$regex = $_ | Select-String "(\w*) => (\w*)"
		[PSCustomObject]@{
			val         = $regex.Matches.Groups[1].value
			replacement = $regex.Matches.Groups[2].value
		}
	}

	$resultingMolecules = New-Object System.Collections.Stack

	#####Part 2
	#Add medicine to the queue, with count of replacements (0)
	#Dequeue, and for each possible reverse replacement add to queue, adding 1 to count of replacements
	#(maybe add to hash/dictionary, and check for duplicates with larger numbers of replacements?)

	#####CURRENTlY
	<#This doesn't finish executing, but by running the bigger reductions first in a depth first search we get to 200 pretty soon, and 
	that's the correct answer.... Would assume that due to not being able to use the bigger reductions later on with won't be improved.#>



	
	$resultingMolecules.Push(
		[PSCustomObject]@{
			state        = $startingMolecule
			replacements = 0
		}
	)

	$minReplacements = [int32]::MaxValue
	$debugCount = 0

	while ($resultingMolecules.Count -gt 0) {
		$debugCount++
		if($debugCount -gt 1001){
			$debugCount=0
			write-host "Queue length: $($resultingMolecules.Count), Min replacements: $minReplacements"
		}
		$molecule = $resultingMolecules.Pop()
		foreach ($transform in $transforms) {
			$finds = Select-String -InputObject $molecule.state -Pattern $transform.replacement -CaseSensitive -AllMatches
			if (-not $finds.matches.count) { continue }
			$finds.matches | % {
				$newMolecule = [PSCustomObject]@{
					state        = $molecule.state.Substring(0, $_.Index) + $transform.val + $molecule.state.Substring($_.Index + $_.Length)
					replacements = $molecule.replacements + 1
				}
				if ( ($newMolecule.state -eq "e") -and 
					 ($newMolecule.replacements -lt $minReplacements)) {
					write-host "A new, better solution found, replacements: $($newMolecule.replacements)"
					$minReplacements = $newMolecule.replacements
				}
				elseif ( ($newMolecule.state.Length -ge 1) -and 
						 ($newMolecule.state -cnotmatch "e") -and
						 ($newMolecule.replacements -lt $minReplacements) ) {
					#If a molecule has an e, but more than that, we can never get down to just e.
					$resultingMolecules.Push($newMolecule)
				}
			}
		}
	}

	$minReplacements

}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/part2_test1.txt" 3
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/part2_test2.txt" 6
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 2: $result" -ForegroundColor Magenta



