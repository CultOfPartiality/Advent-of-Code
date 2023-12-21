. "$PSScriptRoot\..\Unit-Test.ps1"

function Find-AllMirrors{
	param ([string]$Path)

	$blocks = (Get-Content $Path -Raw) -split "`r`n`r`n" | %{,@($_ -split "`r`n")}

	$blocks | %{
		$block = $_
		#work across each row starting at 1
		#if rows are equal, create a top and bottom block by joining all row on either side
		#reverse the top block, limit both strings to the same length
		#if equal, then we have a mirror! 
		$mirroredRowIndexes = 1..($block.Count-1) | %{
			if($block[$_] -eq $block[$_-1]){
				$topBlock = $block[($_-1)..0] -join "|"
				$botBlock = $block[$_..($block.count-1)] -join "|"
				
				$minLen = [math]::Min($topBlock.Length,$botBlock.Length)
				$topBlock = $topBlock.Substring(0,$minLen)
				$botBlock = $botBlock.Substring(0,$minLen)

				if($topBlock -eq $botBlock){
					$_
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
		$mirroredColIndexes = 1..($transBlock.Count-1) | %{
			if($transBlock[$_] -eq $transBlock[$_-1]){
				$topBlock = $transBlock[($_-1)..0] -join "|"
				$botBlock = $transBlock[$_..($transBlock.count-1)] -join "|"
				
				$minLen = [math]::Min($topBlock.Length,$botBlock.Length)
				$topBlock = $topBlock.Substring(0,$minLen)
				$botBlock = $botBlock.Substring(0,$minLen)

				if($topBlock -eq $botBlock){
					$_
				}
			}
		}

		$mirroredRowIndexes*100+$mirroredColIndexes
	} | measure -sum | select -ExpandProperty Sum

}

Unit-Test  ${function:Find-AllMirrors} "$PSScriptRoot\testcases\test.txt" 405
$result = Find-AllMirrors "$PSScriptRoot\input.txt"
Write-Host "Part 1: $result" -ForegroundColor Magenta