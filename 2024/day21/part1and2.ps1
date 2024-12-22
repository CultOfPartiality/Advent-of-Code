. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$arguments = @{Path = "$PSScriptRoot/testcases/test1.txt"; MiddleBots = 2 }

function Solution {
	param ($arguments)

	$codes = get-content $arguments.Path

	function generate-numpadlookup() {
		<#
		+---+---+---+
		| 7 | 8 | 9 |
		+---+---+---+
		| 4 | 5 | 6 |
		+---+---+---+
		| 1 | 2 | 3 |
		+---+---+---+
		  x	| 0 | A |
			+---+---+
	
		No going over gaps
		#>
		$lookup = @{}

		1..3 | % { $lookup["$_,$($_+6)"] = "^^" }
		1..6 | % { $lookup["$_,$($_+3)"] = "^" }
		9..7 | % { $lookup["$_,$($_-6)"] = "vv" }
		9..6 | % { $lookup["$_,$($_-3)"] = "v" }
		1, 4, 7 | % { $lookup["$_,$($_+2)"] = ">>" }
		1, 2, 4, 5, 7, 8 | % { $lookup["$_,$($_+1)"] = ">" }
		3, 6, 9 | % { $lookup["$_,$($_-2)"] = "<<" }
		2, 3, 5, 6, 8, 9 | % { $lookup["$_,$($_-1)"] = "<" }
		#1 to anywhere remaining
		$lookup["1,5"] = "^>", ">^"
		$lookup["1,6"] = ">>^", "^>>"
		$lookup["1,8"] = "^^>", ">^^"
		$lookup["1,9"] = "^^>>", ">>^^"
		$lookup["1,0"] = ">v"
		$lookup["1,A"] = ">>v"
		#2 to anywhere remaining
		$lookup["2,4"] = "^<", "<^"
		$lookup["2,6"] = "^>", ">^"
		$lookup["2,7"] = "^^<", "<^^"
		$lookup["2,9"] = "^^>", ">^^"
		$lookup["2,0"] = "v"
		$lookup["2,A"] = "v>", ">v"
		#3 to anywhere remaining
		$lookup["3,4"] = "^<<", "<<^"
		$lookup["3,5"] = "^<", "<^"
		$lookup["3,7"] = "^^<<", "<<^^"
		$lookup["3,8"] = "^^<", "<^^"
		$lookup["3,0"] = "<v", "v<"
		$lookup["3,A"] = "v"
		#4 to anywhere remaining
		$lookup["4,2"] = "v>", ">v"
		$lookup["4,3"] = "v>>", ">>v"
		$lookup["4,8"] = "^>", ">^"
		$lookup["4,9"] = "^>>", ">>^"
		$lookup["4,0"] = ">vv"
		$lookup["4,A"] = ">>vv"
		#5 to anywhere remaining
		$lookup["5,1"] = "v<", "<v"
		$lookup["5,3"] = "v>", ">v"
		$lookup["5,7"] = "^<", "<^"
		$lookup["5,9"] = "^>", ">^"
		$lookup["5,0"] = "vv"
		$lookup["5,A"] = "vv>", ">vv"
		#6 to anywhere remaining
		$lookup["6,1"] = "<<v", "v<<"
		$lookup["6,2"] = "<v", "v<"
		$lookup["6,7"] = "<<^", "^<<"
		$lookup["6,8"] = "<^", "^<"
		$lookup["6,0"] = "<vv", "vv<"
		$lookup["6,A"] = "vv"
		#7 to anywhere remaining
		$lookup["7,2"] = "vv>", ">vv"
		$lookup["7,3"] = "vv>>", ">>vv"
		$lookup["7,5"] = "v>", ">v"
		$lookup["7,6"] = ">>v", "v>>"
		$lookup["7,0"] = ">vvv"
		$lookup["7,A"] = ">>vvv"
		#8 to anywhere remaining
		$lookup["8,1"] = "<vv", "vv<"
		$lookup["8,3"] = ">vv", "vv>"
		$lookup["8,4"] = "<v", "v<"
		$lookup["8,6"] = ">v", "v>"
		$lookup["8,0"] = "vvv"
		$lookup["8,A"] = ">vvv", "vvv>"
		#9 to anywhere remaining
		$lookup["9,1"] = "<<vv", "vv<<"
		$lookup["9,2"] = "<vv", "vv<"
		$lookup["9,4"] = "<<v", "v<<"
		$lookup["9,5"] = "<v", "v<"
		$lookup["9,0"] = "<vvv", "vvv<"
		$lookup["9,A"] = "vvv"
		#0/A to anywhere remaining
		1..9 | % {
			$rev = $lookup["$_,0"]
			$lookup["0,$_"] = $rev | % {
				$temp = $_ -replace "<", "b" -replace ">", "<" -replace "b", ">"
				$temp = $temp -replace "\^", "c" -replace "v", "^" -replace "c", "v"
				$temp = $temp.tochararray()
				[array]::Reverse($temp)
				-join ($temp)
			}
			$rev = $lookup["$_,A"]
			$lookup["A,$_"] = $rev | % {
				$temp = $_ -replace "<", "b" -replace ">", "<" -replace "b", ">"
				$temp = $temp -replace "\^", "c" -replace "v", "^" -replace "c", "v"
				$temp = $temp.tochararray()
				[array]::Reverse($temp)
				-join ($temp)
			}
		}
		$lookup["0,A"] = ">"
		$lookup["A,0"] = "<"
		
		#Return the lookup for use
		$lookup
	}

	function numpad-sequences([char[]]$reqSeq) {
		#Round 1 - Path finding for the first robot sequence, which gives the keypad order for the next robot
		# Remember, no gaps, find the paths. We'll work out which is shortest and the end (?)
		$lookup = generate-numpadlookup


		$validPaths = @()
		$bot = [PSCustomObject]@{
			pos   = "A"
			steps = 0
			seq   = ""
		}

		$searchSpace = New-Object System.Collections.Queue
		$searchSpace.Enqueue($bot)
		while ($searchSpace.count) {
			$bot = $searchSpace.Dequeue()
			$nextKey = $reqSeq[$bot.steps]
			$paths = $lookup[($bot.pos, $nextKey -join ",")]
			foreach ($possiblePath in ($paths | % { $bot.seq + $_ + "A" })) {
				if ($nextKey -eq "A") {
					$validPaths += $possiblePath
				}
				else {
					$searchSpace.Enqueue([pscustomobject]@{
							pos   = $nextKey
							steps = $bot.steps + 1
							seq   = $possiblePath
						})
				}
			}
		}
		if ($validPaths -is [string]) {
			return , ($validPaths)
		}
		return $validPaths
	}

	$directionalLookup = @{}
	$directionalLookup["A,^"] = "<"
	$directionalLookup["A,>"] = "v"
	
	# THE ORDER ON THIS ONE REALLY MATTERS! It's the difference between getting it and not.
	# See https://www.reddit.com/r/adventofcode/comments/1hjgyps/2024_day_21_part_2_i_got_greedyish/ for details, although one
	# of the comments points out for diagonals:
	#		- When left has to happen , always go left first
	#		- Otherwise, do the up/down first
	$directionalLookup["A,v"] = "<v"#,"v<" 

	$directionalLookup["A,<"] = "v<<"#,"<v<" # Remove sub-optimal case
	$directionalLookup["^,<"] = "v<"
	$directionalLookup["^,v"] = "v"
	$directionalLookup["^,>"] = "v>"#, ">v"
	$directionalLookup["^,A"] = ">"
	$directionalLookup["<,v"] = ">"
	$directionalLookup["<,>"] = ">>"
	$directionalLookup["<,^"] = ">^"
	$directionalLookup["<,A"] = ">>^"#,">^>" # Remove sub-optimal case
	$directionalLookup[">,v"] = "<"
	$directionalLookup[">,<"] = "<<"
	$directionalLookup[">,^"] = "<^"#, "^<" 
	$directionalLookup[">,A"] = "^"
	$directionalLookup["v,<"] = "<"
	$directionalLookup["v,^"] = "^"
	$directionalLookup["v,>"] = ">"
	$directionalLookup["v,A"] = "^>"#, ">^"
	

	function directional-sequences([char[]]$reqSeq) {
		$validPaths = @()
		$bot = [PSCustomObject]@{
			pos   = "A"
			steps = 0
			seq   = ""
		}

		$searchSpace = New-Object System.Collections.Queue
		$searchSpace.Enqueue($bot)
		while ($searchSpace.count) {
			$bot = $searchSpace.Dequeue()
			$nextKey = $reqSeq[$bot.steps]
			if ($reqSeq[$bot.steps] -eq $reqSeq[$bot.steps - 1]) {
				$searchSpace.Enqueue([pscustomobject]@{
						pos   = $nextKey
						steps = $bot.steps + 1
						seq   = $bot.seq + "A"
					})
				continue
			}
			$paths = $directionalLookup[( ($bot.pos, $nextKey) -join ",")]
			foreach ($possiblePath in ($paths | % { $bot.seq + $_ + "A" })) {
				if (($bot.steps + 1) -eq $reqSeq.count) {
					$validPaths += $possiblePath
				}
				else {
					$searchSpace.Enqueue([pscustomobject]@{
							pos   = $nextKey
							steps = $bot.steps + 1
							seq   = $possiblePath
						})
				}
			}
		}

		if ($validPaths -is [string]) {
			return , ($validPaths)
		}
		return $validPaths
	}

	#Depth, start, end (at next layer down) = cost (includes pressing A, i.e. +1)
	$cache = @{}
	function calc ($depth, $start, $end) {
		#Check the cache, and if not found generate is and add it to the cache
		if (-not $cache.ContainsKey( ($depth, $start, $end -join ",") )) {
			# Depth 0 is the main keypad, so just cache the optimal number of instructions for traversing
			# to the desirec destination
			if ($depth -eq 0) {
				$seq = $directionalLookup["$start,$end"]
				$cost = [Int64]($seq.length + 1)
				$cache[ ($depth, $start, $end -join ",") ] = $cost
				return $cost
			}
			# Otherwise, sum up the instruction count to go from "A", through the desired instrcutions, and
			# back to A so we click the button
			else {
				$seq = $directionalLookup["$start,$end"]
				$seq += "A"
				$total = [int64]0
				$prev = "A"
				foreach ($step in $seq.ToCharArray()) {
					$total += (calc ($depth - 1) $prev $step)
					$prev = $step
				}
				$cache[($depth, $start, $end -join ",")] = $total
				return $total
			}
		}
		else {
			return $cache[($depth, $start, $end -join ",")]
		}
	}


	$results = foreach ($code in $codes) {
		$Paths = numpad-sequences $code
		$pathLengths = foreach ($path in $paths) {
			$total = 0
			$prev = "A"
			foreach ($step in $path.ToCharArray()) {
				$total += (calc ($arguments.MiddleBots - 1) $prev $step)
				$prev = $step
			}
			$total
		}
		$shortestSeq = [Int64] ($pathLengths | sort)[0]
		$number = ( [int] ($code -join "").TrimEnd("A") )
		$complexity = $shortestSeq * $number
		# write-host "For $code -> $shortestSeq x $number = $complexity"
		$complexity
	}

	$results | Sum-Array
}

#Part 1
Unit-Test  ${function:Solution} @{Path = "$PSScriptRoot/testcases/test1.txt"; MiddleBots = 2 } 126384
Unit-Test  ${function:Solution} @{Path = "$PSScriptRoot/input.txt"; MiddleBots = 2 } 176650 # Actual soluiont for part 1
$measuredTime = measure-command { $result = Solution @{Path = "$PSScriptRoot/input.txt"; MiddleBots = 2 } }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

#Part 2
Unit-Test  ${function:Solution} @{Path = "$PSScriptRoot/input.txt"; MiddleBots = 25 } 217698355426872 # Actual soluiont for part 2
$measuredTime = measure-command { $result = Solution @{Path = "$PSScriptRoot/input.txt"; MiddleBots = 25 } }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

