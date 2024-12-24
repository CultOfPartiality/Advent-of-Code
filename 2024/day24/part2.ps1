. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input_modified.txt"

# function Solution {
# param ($Path)

$data = get-content $Path
$wires = @{}

$data.where({ $_ -eq "" }, "Until") | % {
	$wire, $value = $_ -split ": "
	$wires[$wire] = $value -eq 1 ? $true : $false
}

$graph = @()

$opindex=0
$gates = $data.where({ $_ -eq "" }, "SkipUntil") | select -Skip 1 | % {
	$a, $op, $b, $q = $_ -split " -> | "
	[PSCustomObject]@{
		A  = $a
		B  = $b
		Op = $op
		Q  = $q
	}
	$graph += "`t$a -> `"$Op $opindex`" -> $q;"
	$graph += "`t$b -> `"$Op $opindex`";"
	$opindex++
}

"digraph G{
	rank1 [style=invisible];
	rank2 [style=invisible];
	rank3 [style=invisible];
	rank4 [style=invisible];
	`n"+
	($graph -join "`n")+
"	{
	rank = same;
	rank1 -> " + (0..44 | %{ ("x"+"$_".PadLeft(2,"0")); ("y"+"$_".PadLeft(2,"0")); } | Join-String -Separator " -> ") + "[ style=invis ];
	}"+
# "	{
# 	rank = same;
# 	rank4 -> " + (0..45 | %{ ("z"+"$_".PadLeft(2,"0")) } | Join-String -Separator " -> ") + "[ style=invis ];
# 	rankdir = LR;
# 	}"+
"}" | Out-File -FilePath "$PSScriptRoot\vis.dot"

# dot -Tsvg "$PSScriptRoot\vis.dot" -o "$PSScriptRoot\vis.svg"
# exit

function run-gates($x,$y,$startGates){

	$gates = $startGates.Clone()
	$wires = @{}
	

	#Set x and y
	for ($i = 0; $i -lt 64; $i++) {
		$wires[("x"+"$i".PadLeft(2,"0"))] = [bool] ([int64]$x -band ([int64]1 -shl $i))
		$wires[("y"+"$i".PadLeft(2,"0"))] = [bool] ([int64]$y -band ([int64]1 -shl $i))
	}

	
	#naive approach
	while ($gates.count) {
		foreach ($gate in $gates) {
			if ( $wires.ContainsKey($gate.A) -and $wires.ContainsKey($gate.B) ) {
				switch ($gate.Op) {
					"AND" { $wires[$gate.Q] = $wires[$gate.A] -and $wires[$gate.B] }
					"OR" { $wires[$gate.Q] = $wires[$gate.A] -or $wires[$gate.B] }
					"XOR" { $wires[$gate.Q] = $wires[$gate.A] -xor $wires[$gate.B] }
				}
				$gates = $gates | ? { $_ -ne $gate }
			}
		}
	}
	
	$result = [int64]0
	foreach ($pair in $wires.GetEnumerator()) {
		if ($pair.Key[0] -eq "z" ) {
			$result = $result -bor ([int64]$pair.Value) -shl ([int]$pair.Key.substring(1))
		}
	}
	
	$result
}


run-gates 1 0 $gates
<# Each bit should look like (except bit 0, and maybe the last bit's carry):

	-----------------------
	prv (previous carry)

	x   XOR y   = add
	x   AND y   = of1 (overflow 1)
	add XOR prv = z
	add AND prv = of2 (overflow 2)
	of1 OR  of2 = cry (carry)
	-----------------------

	Checks
	 - Outs should only come from XORs
	 - "add" should be involved in an XOR to the same bit's z
#>


# $adds = $gates.where({$_.A[0] -in "x","y" -and $_.B[0] -in "x","y" -and $_.Op -eq "XOR"})
# $of1s = $gates.where({$_.A[0] -in "x","y" -and $_.B[0] -in "x","y" -and $_.Op -eq "AND"})
# $outs = $gates.where({$_.Q[0] -eq "z" -and  $_.Op -eq "XOR"})
# $errorsInProgress = $gates.where({$_.Q[0] -eq "z" -and $_.Op -ne "XOR" -and $_.Q -ne "z45"})


# Walk the 'graph', categorising each step as we go

"z15","gds","wrk","cqk","fph","z21","jrs","z34" | sort | Join-String -Separator ","


# }
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

