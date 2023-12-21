. "$PSScriptRoot\..\..\Unit-Test.ps1"

function Check-NonogramRow{
	param ([string]$Row)

	$map,$clue = $Row -split " "
	$clues = $clue -split "," | %{[int]$_}
	$spacesCount = $map.Length - ($clues|measure -Sum).Sum
	$moveableSpaces = $spacesCount - ($clues.count - 1)

	$spaces = 0..($clues.count-1) | %{0}

	#plan is to interate over space options, generate all possible options that are valid with given map

	#Write-Host "Clue: $clue"

	$allFound = $false
	$validCount = 0
	while(-not $allFound){
		#create the thing
		$spareSpaces = $moveableSpaces - ($spaces|measure -sum).sum
		$playArea = 0..($clues.count-1) | %{
			$spacesCount -= $spaces[$_]
			
			('.' * $spaces[$_]) + ('#' * $clues[$_]) + "."
		} | Join-String
		$playArea = ($playArea,('.'*$spareSpaces) -join '').Substring(0,$map.Length)
		
		#check against original map
		#Write-Host $map -ForegroundColor DarkGray
		$valid = (0..($map.Length-1) | %{$map[$_] -eq "?" -or $map[$_] -eq $playArea[$_]} | where{$_ -eq $false}).count -eq 0
		if($valid){
			$validCount++
			#Write-Host $playArea "->" ($spaces -join '') $spareSpaces -ForegroundColor Green
		}
		else{
			#Write-Host $playArea "->" ($spaces -join '') $spareSpaces -ForegroundColor Red
		}

		#go to the next set for spaces
		$spaces[0]++
		0..($spaces.Count-1) | %{
			if( $spaces[$_] -gt $moveableSpaces -or ($spaces|measure -sum).sum -gt $moveableSpaces){
				if($_ -eq $spaces.count-1){
					$allFound = $true
				}
				else{
					$spaces[$_] = 0
					$spaces[$_+1]++
				}
			}
		}
	}
	#output 
	$validCount
}

Unit-Test ${function:Check-NonogramRow} "???.### 1,1,3" 1
Unit-Test ${function:Check-NonogramRow} ".??..??...?##. 1,1,3" 4
Unit-Test ${function:Check-NonogramRow} "?#?#?#?#?#?#?#? 1,3,1,6" 1
Unit-Test ${function:Check-NonogramRow} "????.#...#... 4,1,1"  1
Unit-Test ${function:Check-NonogramRow} "????.######..#####. 1,6,5" 4
Unit-Test ${function:Check-NonogramRow} "?###???????? 3,2,1" 10

$result = Get-Content "$PSScriptRoot\input.txt" | %{
	Check-NonogramRow $_
} | measure -sum | select -ExpandProperty Sum

Write-Host "Part 1: $result" -ForegroundColor Magenta
