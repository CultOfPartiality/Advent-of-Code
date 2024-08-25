. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$string = "{{<!!>},{<!!>},{<!!>},{<!!>}}"

function Solution {
	param ($string)

	# Oh boy. Regex seems like it might finally be not the vibe. Almost
	# 
	# Ok, step one: remove all !'s and their canceled characters, then remove the garbage
	# Now we have to workout the groups. Recursion to the rescue again
	$stringCleanedUp = $string -replace "!.", "" -replace "<[^>]*>", ""

	function Calc-Score {
		param($string, $mulitplier)
		$score = 0
		if ($string -eq "{}") {
			$score += $mulitplier
		}
		else {
			# Oh boy, this one is a bit over my head. Should study this in future
			#  - https://stackoverflow.com/questions/546433/regular-expression-to-match-balanced-parentheses
			$firstGroupMatch = ($string | Select-String "{(?>{(?<c>)|[^{}]+|}(?<-c>))*(?(c)(?!))}" -AllMatches).Matches.Groups | ? { $_.Success }
			
			foreach ($result in $firstGroupMatch) {				
				if ($result.Value -eq "{}") {
					$score += $mulitplier
				}
				else {
					# Then recurse, but with a higher score
					$score += $mulitplier
					$newString = $result.Value.Substring(1, $result.Length - 2)
					$score += Calc-Score ($newString) ($mulitplier + 1)
				}
			}
		}
		$score
	}

	Calc-Score $stringCleanedUp 1

}
Unit-Test  ${function:Solution} "{}" 1
Unit-Test  ${function:Solution} "{{{}}}" 6
Unit-Test  ${function:Solution} "{{{},{},{{}}}}" 16
Unit-Test  ${function:Solution} "{<a>,<a>,<a>,<a>}" 1
Unit-Test  ${function:Solution} "{{<ab>},{<ab>},{<ab>},{<ab>}}" 9
Unit-Test  ${function:Solution} "{{<!!>},{<!!>},{<!!>},{<!!>}}" 9
Unit-Test  ${function:Solution} "{{<a!>},{<a!>},{<a!>},{<ab>}}" 3
$measuredTime = measure-command { $result = Solution (get-content "$PSScriptRoot\input.txt") }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

