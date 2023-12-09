$inputSource = "$PSScriptRoot/input.txt"
#$inputSource = "$PSScriptRoot/example.txt"

$bookletRaw = get-Content $inputSource | Select-String -CaseSensitive '((?<L>[\da-z]*) )? ?(?<OP>NOT|AND|OR|LSHIFT|RSHIFT)? ?(?<R>\w*) -> (?<AS>\w*)' | select -ExpandProperty Matches
$wires = @{}

$booklet = $bookletRaw.Clone()

$solved = $false
$i = 0
while(-not $wires."a"){
	if(-not $booklet){
		Write-Host "If example, then answer: i= $($wires."i"). If real, then something went wrong"
		exit
	}
	$booklet = $booklet|%{
		$OP,$R,$L,$AS = $_.Groups["OP","R","L","AS"]
		$assign = -not $OP.Success
		$RValue = $R.Value -match '\d+' ? [UInt16]$R.Value : $wires."$($R.Value)"
		$LValue = $L.Value -match '\d+' ? [UInt16]$L.Value : $wires."$($L.Value)"
		switch ($_) {
			#If the right wire is nothing, then move on
			{$RValue -eq $null}{$_ ; break}
			
			#Literal or wire-to-wire assignment : "1234 -> hl" or "ab -> hl"
			{$assign}{$wires."$($AS.Value)" = $RValue; break}
			#NOT (Note - Powershell fucks up bit inversion, so this is the cleanest way I found to convert back)
			{$OP.Value -eq "NOT" }{$wires."$($AS.Value)" = -bnot $RValue -band [UInt16]::MaxValue;break}
			
			#From after here, the left wire needs to be valid
			{$LValue -eq $null} {$_; break}

			#AND
			{$OP.Value -eq "AND" }{$wires."$($AS.Value)" = $LValue -band $RValue; break}
			#OR
			{$OP.Value -eq "OR" }{$wires."$($AS.Value)" = $LValue -bor $RValue; break}
			#LSHIFT
			{$OP.Value -eq "LSHIFT" }{$wires."$($AS.Value)" = $LValue -shl $RValue; break}
			#RSHIFT
			{$OP.Value -eq "RSHIFT" }{$wires."$($AS.Value)" = $LValue -shr $RValue; break}

			Default {write-host "Error, you didn't take some thing into account"}
		}
	}
	Write-Host "$($booklet.Count) out of 339 left to go"
}

write-host "Part 1: $($wires."a")"