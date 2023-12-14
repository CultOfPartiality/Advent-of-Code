. "$PSScriptRoot\..\Unit-Test.ps1"


function Count-StringDiffs {
	param (
		[string]$A,
		[string]$B
	)
	
	$sum = 0
	for ($i = 0; $i -lt $A.Length; $i++) {
		if($A[$i] -ne $B[$i]){$sum++}
	}
	$sum
}

function Find-AllMirrors{
	param ([string]$Path)

	$blocks = (Get-Content $Path -Raw) -split "`r`n`r`n" | %{,@($_ -split "`r`n")}

	$blocks | %{
		$block = $_
		#work across each row starting at 1
		#if rows are equal, create a top and bottom block by joining all row on either side
		#reverse the top block, limit both strings to the same length
		#if equal, then we have a mirror! 

		#find the original mirror line from part 1 (if there was one)
		$originaRow = $null
		1..($block.Count-1) | %{
			if($block[$_] -eq $block[$_-1]){
				$topBlock = $block[($_-1)..0] -join "|"
				$botBlock = $block[$_..($block.count-1)] -join "|"
				
				$minLen = [math]::Min($topBlock.Length,$botBlock.Length)
				$topBlock = $topBlock.Substring(0,$minLen)
				$botBlock = $botBlock.Substring(0,$minLen)

				if($topBlock -eq $botBlock){
					$originaRow = $_
				}
			}
		}
		$mirroredRowIndexes = 1..($block.Count-1) | %{
			#Allow for one possible difference
			if( (Count-StringDiffs $block[$_] $block[$_-1]) -le 1 ){
				$topBlock = $block[($_-1)..0] -join "|"
				$botBlock = $block[$_..($block.count-1)] -join "|"
				
				$minLen = [math]::Min($topBlock.Length,$botBlock.Length)
				$topBlock = $topBlock.Substring(0,$minLen)
				$botBlock = $botBlock.Substring(0,$minLen)
				
				#Demand one possible difference, and make sure its not the same mirror as part 1
				if( (Count-StringDiffs $topBlock $botBlock ) -eq 1  -and $_ -ne $originaRow){
					$_
					#TODO need to work out the location/s of the difference?
				}
			}
		}

		#transpose array of strings
		$transBlock = 0..($block[0].Length-1) | %{
			$col = $_
			0..($block.Count-1) | %{
				$row = $_
				$block[$row][$col]
			} | Join-String
		}

		#now do columns
		$originalCol = $null
		1..($transBlock.Count-1) | %{
			#find the original mirror line from part 1 (if there was one)
			if($transBlock[$_] -eq $transBlock[$_-1]){
				$topBlock = $transBlock[($_-1)..0] -join "|"
				$botBlock = $transBlock[$_..($transBlock.count-1)] -join "|"
				
				$minLen = [math]::Min($topBlock.Length,$botBlock.Length)
				$topBlock = $topBlock.Substring(0,$minLen)
				$botBlock = $botBlock.Substring(0,$minLen)

				if($topBlock -eq $botBlock){
					$originalCol = $_
				}
			}
		}
		$mirroredColIndexes = 1..($transBlock.Count-1) | %{
			#Allow for one possible difference
			if( (Count-StringDiffs $transBlock[$_] $transBlock[$_-1]) -le 1 ){
				$topBlock = $transBlock[($_-1)..0] -join "|"
				$botBlock = $transBlock[$_..($transBlock.count-1)] -join "|"
				
				$minLen = [math]::Min($topBlock.Length,$botBlock.Length)
				$topBlock = $topBlock.Substring(0,$minLen)
				$botBlock = $botBlock.Substring(0,$minLen)

				#Demand one difference, and that this not be the same as part 1
				if( ( Count-StringDiffs $topBlock $botBlock) -eq 1  -and $_ -ne $originalCol){
					$_
				}
			}	
		}

		$mirroredRowIndexes*100+$mirroredColIndexes
	} | measure -sum | select -ExpandProperty Sum

}

Unit-Test  ${function:Find-AllMirrors} "$PSScriptRoot\testcases\test.txt" 400
$result = Find-AllMirrors "$PSScriptRoot\input.txt"
Write-Host "Part 2: $result" -ForegroundColor Magenta