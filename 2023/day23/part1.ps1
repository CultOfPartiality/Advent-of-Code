. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#function Solution {
#    param ($Path)

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

$data = get-content $Path

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
				stepsToHere      = [int]::MinValue
				cameFrom         = $null
			}
		})
	$row
	$y++
}
$maxX = $x
$maxY = $y
$start = $data[0][1]
$start.stepsToHere = 0

#we're implementing A*, but trying for the longest path... 
$nodesToInvestigate = New-Object "System.Collections.Generic.PriorityQueue[psobject,int]"
$nodesToInvestigate.Enqueue($start, 0)

while ($nodesToInvestigate.Count -gt 0) {
	$currentNode = $nodesToInvestigate.Dequeue()

	# if ($currentNode.coords -eq ($maxX-1, $maxY)) {
	# 	#We've found the goal!
	# 	break
	# }

	$neighbours = @(
		@( ($currentNode.coords.x + 1), $currentNode.coords.y, 'Right'),
		@( ($currentNode.coords.x - 1), $currentNode.coords.y, 'Left'),
		@(  $currentNode.coords.x, ($currentNode.coords.y + 1), 'Down'),
		@(  $currentNode.coords.x, ($currentNode.coords.y - 1), 'Up' )
	).where({ $_ -notcontains -1 }).where({ $_ -notcontains $data.Count })
	
	foreach($coordsAndDirec in $neighbours){
		$neighbour = $data[$coordsAndDirec[1]][$coordsAndDirec[0]]
        $direction = $coordsAndDirec[2]
        #Skip stones and sloped in the wrong direction
        if($neighbour.type -eq $stone){continue}
        if( @( 'UpV','Down^','Left>','Right<') -contains "$($direction)$($neighbour.type)" ){continue}
        
        $possibleScore = $currentNode.stepsToHere + $neighbour.cost
		if ($possibleScore -gt $neighbour.stepsToHere) {
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

"       Steps to Get Here        "
"--------------------------------"
$data|%{
	$_ | %{
        $node = $_
        switch ($_.type) {
            $stone { Write-Host '## ' -ForegroundColor DarkGray -NoNewline }
            $garden{ Write-Host ($node.stepsToHere.ToString().PadLeft(2,"0")+" ") -ForegroundColor Blue -NoNewline }
            default {Write-Host 'SS ' -ForegroundColor Green -NoNewline}
        }
    }
    Write-Host
}

    
#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta

