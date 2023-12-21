. "$PSScriptRoot\..\Unit-Test.ps1"
. "$PSScriptRoot\..\UsefulStuff.ps1"

function Solution {
   param ($Path,$TotalSteps)

#The following lines are for development
# $Path = "$PSScriptRoot/testcases/test1.txt"
# $TotalSteps = 6

#defines
$stone = '#'
$garden = '.'

$y=0
$data = Get-Content $Path | % {
	$x = 0
	$row = , @([char[]]$_ | % {
			[PSCustomObject]@{
				coords           = [PSCustomObject]@{x = $x++; y = $y }
				type             = $_
                cost             = 1
				stepsToHere      = [int]::MaxValue
				cameFrom         = $null
			}
		})
	$row
	$y++
}
$start = $data|%{$_}|?{$_.type -eq "S"}
$start.stepsToHere = 0

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
	
	foreach($coords in $neighbours){
		$neighbour = $data[$coords[1]][$coords[0]]
        if($neighbour.type -eq $stone){continue}
		$possibleScore = $currentNode.stepsToHere + $neighbour.cost
		if ($possibleScore -lt $neighbour.stepsToHere) {
			$neighbour.cameFrom = $currentNode
			$neighbour.stepsToHere = $possibleScore
			if ($nodesToInvestigate.UnorderedItems -notcontains $neighbour) {
				$nodesToInvestigate.Enqueue($neighbour, $neighbour.stepsToHere)
			}
		}
	}

	#Debug
	#Write-Host
	#$currentNode
	#($data|%{$_.cheapestCostHere | %{$_.ToString().PadLeft(2,"0")}|Join-String -Separator ' '})
}

# "       Steps to Get Here        "
# "--------------------------------"
# $data|%{
# 	$_ | %{
#         $node = $_
#         switch ($_.type) {
#             $stone { Write-Host '## ' -ForegroundColor DarkGray -NoNewline }
#             $garden{ Write-Host ($node.stepsToHere.ToString().PadLeft(2,"0")+" ") -ForegroundColor Blue -NoNewline }
#             default {Write-Host 'SS ' -ForegroundColor Green -NoNewline}
#         }
#     }
#     Write-Host
# }

#count all even spaces with steps less or equal to total steps
($data.stepsToHere).Where{$_ -le $TotalSteps -and $_ % 2 -eq 0}.Count

}

Unit-Test  ${function:Solution} @("$PSScriptRoot/testcases/test1.txt",6) 16
$result = Solution "$PSScriptRoot\input.txt" 64
Write-Host "Part 1: $result" -ForegroundColor Magenta

