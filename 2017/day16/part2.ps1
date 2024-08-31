. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/input.txt"

# function Solution {
# 	param ($Path)

	# Parse instructions
	$instructions = (get-content $Path) -split "," | % {
		$text = $_
		$op = $_[0]
		$args = $_.Substring(1)
		$split = $args -split "/"
		switch ($op) {
			's' {
				$arg1 = [int]$args
				$arg2 = $null
			}
			'x' {
				$arg1 = [int]$split[0]
				$arg2 = [int]$split[1]
			}
			'p' {
				$arg1 = [char]$split[0]
				$arg2 = [char]$split[1]
			}
		}
		[PSCustomObject]@{
			op   = $op
			arg1 = $arg1
			arg2 = $arg2
		}
	}

	# Setup dance
	$startingOrder = 'a'..'p'
	$order = 'a'..'p'

	# Loop over instructions once, which gets us the transform to apply to each string
	foreach ($instruction in $instructions) {
		switch ($instruction.op) {
			's' {
				if ($instruction.arg1 -notin (0, $order.Count)) {
					$index = $order.count - $instruction.arg1
					$order = $order[$index..($order.Count - 1)] + $order[0..($index - 1)]
				}
			}
			'x' {
				$temp = $order[$instruction.arg1]
				$order[$instruction.arg1] = $order[$instruction.arg2]
				$order[$instruction.arg2] = $temp
			}
			'p' {
				$index1 = $order.IndexOf($instruction.arg1)
				$index2 = $order.IndexOf($instruction.arg2)
				$temp = $order[$index1]
				$order[$index1] = $order[$index2]
				$order[$index2] = $temp
			}
		}
	}

	# Now starting from the start order, work out the new indexes that one round does
	# The array is (in order) the index of the previous round that should go there
	write-host "Initial: " ('a'..'p' -join '')
	write-host "Round 1: " ($order -join "")
	$prevIndexes = $order | %{
		$startingOrder.IndexOf($_)
	}
	$testOrder = $prevIndexes | %{ $startingOrder[$_]}
	write-host "Test sp: " ($testOrder -join "")
	
	# Still, running 1 billion rounds is too slow. So we need to work out the isolated loops
	# and just rotate them with modulus maths. Say if 1->5->2->1, then that's a loop of 3.
	# 1 billion % 3 = 1, so we just apply one round of that transform
	
	$order -join ""
    
# }
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" "paedcbfghijklmno"
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

