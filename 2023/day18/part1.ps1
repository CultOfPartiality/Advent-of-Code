. "$PSScriptRoot\..\Unit-Test.ps1"
. "$PSScriptRoot\..\UsefulStuff.ps1"

function Solution {
	param ($Path)

	#The following line is for development
	#$Path = "$PSScriptRoot/testcases/test1.txt"
	#$Path = "$PSScriptRoot/input.txt"

	$data = get-content $Path

	#get data
	$nodes = $data | % {
		$direction, $length, $colour = $_ -split " "
		[PSCustomObject]@{
			direction = $direction
			length    = $length
			colour    = $colour
		}
	}

	#Generate the nodes of the path
	$gradualNodes = New-Object object[] ($nodes.Count + 1)
	$gradualNodes[0] = [PSCustomObject]@{x = 0; y = 0; direction = ""; colour = "" }
	for ($i = 0; $i -lt $nodes.Count; $i++) {
		$node = $nodes[$i]
		$gradualNodes[$i + 1] = [PSCustomObject]@{
			x         = $gradualNodes[$i].x
			y         = $gradualNodes[$i].y
			direction = $node.direction
			colour    = $node.colour
		}
	
		switch ($nodes[$i].direction) {
			'R' { $gradualNodes[$i + 1].x += $node.length }
			'L' { $gradualNodes[$i + 1].x -= $node.length }
			'D' { $gradualNodes[$i + 1].y += $node.length }
			'U' { $gradualNodes[$i + 1].y -= $node.length }
		}
	}

	#normalise the nodes, so min x and y are 1
	$minX = $gradualNodes.x | measure -Minimum | select -ExpandProperty Minimum
	$minY = $gradualNodes.y | measure -Minimum | select -ExpandProperty Minimum
	$gradualNodes = $gradualNodes | % { $_.x += - [int]$minX + 1; $_.y += - [int]$minY + 1; $_ }
	$maxX = $gradualNodes.x | measure -Maximum | select -ExpandProperty Maximum
	$maxY = $gradualNodes.y | measure -Maximum | select -ExpandProperty Maximum

	#create a grid of the right size (allowing a boundry)
	$layout = 0..($maxY + 1) | % { , @(0..($maxX + 1) | % { "." }) }

	#loop over gradual nodes, adding # to path, 1 to the left, 2 to the right
	$coords = [PSCustomObject]@{x = 1; y = 1 }
	foreach ($node in $gradualNodes) {
		#work out what is "left"
		switch ($node.direction) {
			'R' {
				$coords.x..$node.x | % {
					$layout[$coords.y][$_] = "#"
					$layout[$coords.y + 1][$_] = $layout[$coords.y + 1][$_] -eq "." ? "2" : $layout[$coords.y + 1][$_]
					$layout[$coords.y - 1][$_] = $layout[$coords.y - 1][$_] -eq "." ? "1" : $layout[$coords.y - 1][$_]
				}
			}
			'L' {
				$coords.x..$node.x | % {
					$layout[$coords.y][$_] = "#"
					$layout[$coords.y + 1][$_] = $layout[$coords.y + 1][$_] -eq "." ? "1" : $layout[$coords.y + 1][$_]
					$layout[$coords.y - 1][$_] = $layout[$coords.y - 1][$_] -eq "." ? "2" : $layout[$coords.y - 1][$_]
				}
			}
			'D' {
				$coords.y..$node.y | % {
					$layout[$_][$coords.x] = "#"
					$layout[$_][$coords.x + 1] = $layout[$_][$coords.x + 1] -eq "." ? "1" : $layout[$_][$coords.x + 1]
					$layout[$_][$coords.x - 1] = $layout[$_][$coords.x - 1] -eq "." ? "2" : $layout[$_][$coords.x - 1]
				}
			}
			'U' {
				$coords.y..$node.y | % {
					$layout[$_][$coords.x] = "#"
					$layout[$_][$coords.x + 1] = $layout[$_][$coords.x + 1] -eq "." ? "2" : $layout[$_][$coords.x + 1]
					$layout[$_][$coords.x - 1] = $layout[$_][$coords.x - 1] -eq "." ? "1" : $layout[$_][$coords.x - 1]
				}
			}
		}
		$coords.x, $coords.y = $node.x, $node.y

	}

	#whatever number is in the top row is the "outside" number
	$outside = ($layout[0] | group | ? { $_.Name -ne "." }).Name
	$inside = "1", "2" -ne $outside

	$layout | % {
 		($_ -join "" | select-string "#[^$outside]*#" -AllMatches).Matches.Value | %{$_.Length}
	} | measure -sum | select -ExpandProperty Sum

	#Debug
	#$layout | %{[char[]]$_ -join ""}

}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 62
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 1: $result" -ForegroundColor Magenta

