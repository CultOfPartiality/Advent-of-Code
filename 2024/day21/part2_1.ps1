. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

# function Solution {
# 	param ($Path)

$codes = get-content $Path

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

	#Double check lookup
		(Get-AllPairs (0..9 + "A")) | % {
		if ($null -eq $lookup[$_ -join ","]) {
			write-host ($_ -join ",")
			exit
		}
	}


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
		if ($paths -eq $null) {
			write-host "ERROR - Missing lookup entry $(($bot.pos, $nextKey -join ","))"
			exit
		}
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
$directionalLookup["A,v"] = "v<"#,"<v"
$directionalLookup["A,<"] = "v<<"#,"<v<" # Remove sub-optimal case, slows it down a lot
$directionalLookup["^,<"] = "v<"
$directionalLookup["^,v"] = "v"
$directionalLookup["^,>"] = "v>"#,">v" #Each option ends up facing the wrong way for a run of the same directino
$directionalLookup["^,A"] = ">"
$directionalLookup["<,v"] = ">"
$directionalLookup["<,>"] = ">>"
$directionalLookup["<,^"] = ">^"
$directionalLookup["<,A"] = ">>^"#,">^>" # Remove sub-optimal case, slows it down a lot
$directionalLookup[">,v"] = "<"
$directionalLookup[">,<"] = "<<"
$directionalLookup[">,^"] = "<^"#,"^<" 
$directionalLookup[">,A"] = "^"
$directionalLookup["v,<"] = "<"
$directionalLookup["v,^"] = "^"
$directionalLookup["v,>"] = ">"
$directionalLookup["v,A"] = "^>"#,">^" # > is a better ending spot?

$stage2Lookup = @{
	"A"  = "A"
	"^A" = "<A>A"
	">A" = "vA^A"
	"vA" = "v<A>^A"
	"<A" = "v<<A>>^A"
}
	

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


$stage2Lookup = @{
	"A"  = "A"
	"^A" = "<A>A"
	">A" = "vA^A"
	"vA" = "v<A>^A"
	"<A" = "v<<A>>^A"
}

$results = foreach ($code in $codes) {
	write-host "Working on $code"
		
	$seq = numpad-sequences $code | % { directional-sequences $_ } | sort length | select -first 1
		
	# Since we always end back on the A at every stage:
	# 	- Number of "<" and ">" must always be equal
	# 	- Number of "^" and "v" must always be equal
	# Since the previous cycle needs X button pushes:
	# 	- The number of "A"s is the count of symbols from the previous cycle
		
	2..25 | % {
		#Work out the shortest path for each operation required from the previous cycle
		$index = 0
		$startIndex = 0
		$newString = ""
		$bits = & {
			while ($index -le $seq.length) {
				while ($seq[$index] -ne "A" -and $index -le $seq.length) { $index++ }
				if($seq[$index] -ne "A"){continue}
				$segment = $seq[$startIndex..$index]
				if (-not $stage2Lookup.ContainsKey( -join ($segment))) {
					#Make new lookup
					$newLookup = ""
					$prev = "A"
					for ($i = 0; $i -lt $segment.length; $i++) {
						$newLookup += $directionalLookup[$prev, $segment[$i] -join ","] + "A"
						$prev = $segment[$i]
					}
					$stage2Lookup[ -join ($segment)] = $newLookup
					write-host "Stage 2 lookup now $($stage2Lookup.Count) entries"
				}
				
				$stage2Lookup[ -join ($segment)]
				$startIndex = $index = $index + 1
			}
		}
		$seq = -join ($bits)
	}

	$shortestSeq = $seq

	$number = ( [int] ($code -join "").TrimEnd("A") )
	$complexity = $shortestSeq.length * $number
	write-host "For $code -> $($shortestSeq.length) x $number = $complexity"
	$complexity

}

$results | sum-array

# # }
# # Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 126384
# # Unit-Test  ${function:Solution} "$PSScriptRoot/input.txt" 176650
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

