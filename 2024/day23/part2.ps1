. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
	param ($Path)

	$connections = get-content $Path | % { , ($_ -split "-") }
	$PCs = @{}
	
	foreach($conn in $connections){
		if($PCs.ContainsKey($conn[0])){ $PCs[$conn[0]] += $conn[1] }
		else{ $PCs[$conn[0]] = @($conn[1]) }

		if($PCs.ContainsKey($conn[1])){ $PCs[$conn[1]] += $conn[0] }
		else{ $PCs[$conn[1]] = @($conn[0]) }
	}

	$networks = foreach($PC in $PCs.Keys){
		$Connections = $PCs[$PC]

		$nextConnSetsRaw = foreach($conn in $Connections){
			$commonConns = [array]( $PCs[$conn] | ?{$_ -in $Connections} )
			, ($commonConns + $conn )
		}
		$nextConnSets = $nextConnSetsRaw | ?{ $_ -is [Array] }

		$nextConnSets = $nextConnSets | %{((([array]$_)+$PC) | sort) -join "," } | group
		$nextConnSets | %{
			$_.Name
		}
	}
	$networks | group | sort Count -Descending | select -first 1 -ExpandProperty Name
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" "co,de,ka,ta"
Unit-Test  ${function:Solution} "$PSScriptRoot/input.txt" "er,fh,fi,ir,kk,lo,lp,qi,ti,vb,xf,ys,yu"
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

