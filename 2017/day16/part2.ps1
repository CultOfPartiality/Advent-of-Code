. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/input.txt"

function Solution {
	param ($Path)

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
	$order = 'a'..'p'
	$prevOrder = @{}
	$prevOrder[$order -join ""] = 0

	function Run-Ops ($order) {
		foreach ($instruction in $instructions) {
			switch ($instruction.op) {
				's' {
					if ($instruction.arg1 -notin (0, $order.Count)) {
						$index = $order.count - $instruction.arg1
						$order = $order[$index..($order.Count - 1)] + $order[0..($index - 1)]
					}
				}
				'x' {
					$order[$instruction.arg2], $order[$instruction.arg1] = $order[$instruction.arg1], $order[$instruction.arg2]
				}
				'p' {
					$index1 = $order.IndexOf($instruction.arg1)
					$index2 = $order.IndexOf($instruction.arg2)
					$order[$index1], $order[$index2] = $order[$index2], $order[$index1]
				}
			}
		}
		$order
	}

	# Loop over instructions in rounds until we find a repeat
	for ($i = 0; $i -lt 1000000000; $i++) {
		$order = Run-Ops($order)
		if ($prevOrder.ContainsKey($order -join "")) {
			#We've found a loop
			$i++
			break
		}
		$prevOrder[$order -join ""] = $i
	}

	$loopCount = $i - $prevOrder[$order -join ""]
	$extraPerms = 1000000000 % $loopCount
	write-host "The ops loop after $loopCount iterations, so running that many ops is the same as doing nothing"
	write-host "Thus, 1000000000 % $loopCount is $extraPerms extra rounds to get there after the last rounds"
	for ($i = 0; $i -lt $extraPerms; $i++) {
		$order = Run-Ops($order)
	}

	write-host "Initial: " ('a'..'p' -join '')
	write-host "Final  : " ($order -join '')
	$order -join ""

}
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

