. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input_part2.txt"

# function Solution {
# 	param ($Path)


	$data = get-content $Path
	$password = $data[0].ToCharArray()
	#Reverse instructions order, and invert instructions
	$instructions = $data[($data.Count-1)..0] | % {
		$parts = $_ -split " "
		switch ($null) {
			{ $parts[0] -eq "swap" -and $parts[1] -eq "position" } { 
				[PSCustomObject]@{
					op   = "swapPos"
					pos1 = [int]$parts[5]
					pos2 = [int]$parts[2]
				}
			}
			{ $parts[0] -eq "swap" -and $parts[1] -eq "letter" } {
				[PSCustomObject]@{
					op   = "swapLet"
					let1 = [char]$parts[5]
					let2 = [char]$parts[2]
				}
			}
			{ $parts[0] -eq "rotate" -and $parts[1] -in ("left", "right") } {
				[PSCustomObject]@{
					op    = "rotateDir"
					dir   = $parts[1] -eq "left" ? "right" : "left"
					steps = ([int]$parts[2]) % $password.Count
				}
			}
			{ $parts[0] -eq "rotate" -and $parts[1] -eq "based" } {#will need to reverse in code
				[PSCustomObject]@{
					op  = "rotateLet"
					let = [char]$parts[6]
				}
			}
			{ $parts[0] -eq "reverse" } { 
				[PSCustomObject]@{
					op    = "reverse"
					start = [int]$parts[2]
					end   = [int]$parts[4]
				}
			}
			{ $parts[0] -eq "move" } { 
				[PSCustomObject]@{
					op       = "move"
					oldIndex = [int]$parts[5]
					newIndex = [int]$parts[2]
				}
			}
		}
	}

	$instructionNum = 102
	foreach ($instruction in $instructions) {
		$instructionNum--
		switch ($instruction.op) {
			"swapPos" {
				$let1 = $password[$instruction.pos1]
				$let2 = $password[$instruction.pos2]
				$password[$instruction.pos1] = $let2
				$password[$instruction.pos2] = $let1
			}
			"swapLet" {
				$let1Index = $password.IndexOf([char]$instruction.let1)
				$let2Index = $password.IndexOf($instruction.let2)
				$password[$let1Index] = $instruction.let2
				$password[$let2Index] = $instruction.let1
			}
			"reverse" {
				$startIndex = $instruction.start
				$endIndex = $instruction.end
				while ($startIndex -lt $endIndex) {
					$temp = $password[$startIndex]
					$password[$startIndex] = $password[$endIndex]
					$password[$endIndex] = $temp
					$startIndex++
					$endIndex--
				}
			}
			"rotateDir" {
				if ($instruction.steps) {
					if ($instruction.dir -eq 'right') {
						$password = $password[($password.Count - $instruction.steps)..($password.Count - 1)] + $password[0..($password.Count - $instruction.steps - 1)]
					}
					else {
						$password = $password[$instruction.steps..($password.Count - 1)] + $password[0..($instruction.steps - 1)]
					}
				}
			}
			"rotateLet" {
				#reversed direction, but need to work out how far to go back....
				$index = $password.IndexOf($instruction.let)
				
				$steps = 1 #if the character was originally in index 0
				$originalIndex = 0
				
				while((10*$password.Count + $index-$steps) % $password.Count -ne $originalIndex){
					$steps++
					$originalIndex++
					if($originalIndex -eq 4){$steps++}
				}
				$steps = $steps % $password.Count
				if ($steps) {
					$password = $password[$steps..($password.Count - 1)] + $password[0..($steps - 1)]
				}
			}
			"move" {
				$char = $password[$instruction.oldIndex]
				$index = 0
				$password = for ($i = 0; $i -lt $password.Count; $i++) {
					if ( ($instruction.oldIndex -gt $instruction.newIndex -and $i -eq $instruction.oldIndex + 1) -or 
					    ($instruction.oldIndex -lt $instruction.newIndex -and $i -eq ($instruction.oldIndex))  ) {
						$index++
						$password[$index]
						$index++
					}
					elseif ($i -eq $instruction.newIndex) {
						$char
					}
					else {
						$password[$index]
						$index++
					}
				}
			}
		}
		write-host "Line $($instructionNum): $($instruction.op) -> "($password -join "")
		$z = $z
	}
	$password -join ""

# }

# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test_rotateLeft.txt" "deabc"
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test_rotateRight.txt" "deabc"
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test_rotateMove2.txt" "adbce"
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test_rotateMoveError.txt" "acdefbgh"
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" "decab"
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

