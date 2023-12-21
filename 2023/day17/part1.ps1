. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#function Solution {
#    param ($Path)

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

$data = get-content $Path
$maxX = $data[0].Length - 1
$maxY = $data.Count - 1
$x = 0
$y = 0
$data = $data | % {
	$x = 0
	$row = , @([char[]]$_ | % {
			[PSCustomObject]@{
				coords           = [PSCustomObject]@{x = $x++; y = $y }
				cost             = [int]"$_"
				cheapestCostHere = [int]::MaxValue
				cameFrom         = $null
			}
		})
	$row
	$y++
}
$start = $data[0][0]

$start.cheapestCostHere = 0

#we're implementing A* I guess
$nodesToInvestigate = New-Object "System.Collections.Generic.PriorityQueue[psobject,int]"
$nodesToInvestigate.Enqueue($start, 0)

while ($nodesToInvestigate.Count -gt 0) {
	$currentNode = $nodesToInvestigate.Dequeue()

	if ($currentNode.coords -eq ($maxX, $maxY)) {
		#We've found the goal!
		break
	}

	$neighbours = @(
		@( ($currentNode.coords.x + 1), $currentNode.coords.y ),
		@( ($currentNode.coords.x - 1), $currentNode.coords.y ),
		@(  $currentNode.coords.x, ($currentNode.coords.y + 1) ),
		@(  $currentNode.coords.x, ($currentNode.coords.y - 1) )
	).where({ $_ -notcontains -1 }).where({ $_ -notcontains $data.Count })
	
	$neighbours | % {
		$neighbour = $data[$_[1]][$_[0]]
		$possibleScore = $currentNode.cheapestCostHere + $neighbour.cost
		if ($possibleScore -lt $neighbour.cheapestCostHere) {
			$neighbour.cameFrom = $currentNode
			$neighbour.cheapestCostHere = $possibleScore
			if ($nodesToInvestigate.UnorderedItems -notcontains $neighbour) {
				$nodesToInvestigate.Enqueue($neighbour, $neighbour.cheapestCostHere)
			}
		}
	}

	#Debug
	#Write-Host
	#$currentNode
	#($data|%{$_.cheapestCostHere | %{$_.ToString().PadLeft(2,"0")}|Join-String -Separator ' '})

}

"      Cheapest Cost to Get Here               Points to ComesFrom              Cost per Node"
"--------------------------------------     -------------------------     -------------------------"
$data|%{
	($_.cheapestCostHere | %{$_.ToString().PadLeft(2,"0")}|Join-String -Separator ' ')+"     "+
	($_ | % {
		$char = switch ("$($_.coords.x-$_.cameFrom.coords.x),$($_.coords.y-$_.cameFrom.coords.y)") {
			'-1,0' { ">" }
			'1,0'  { "<" }
			'0,1'  { "^" }
			'0,-1' { "v" }
			default {"."}
		}
		$char.ToString().PadLeft(1, "0") } | Join-String -Separator ' ' )+"     "+
	($_.cost | %{$_.ToString().PadLeft(1,"0")}|Join-String -Separator ' ')


}


    
#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta

