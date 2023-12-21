#Get input
#$inputSource = "$PSScriptRoot/example.txt"
$inputSource = "$PSScriptRoot/input.txt"

$data = Get-Content $inputSource | % {
    $hand = ([char[]]$_)[0..4]
    $bid = [int] [Regex]::Match($_, ' \d+').Value
	
	$handTypeRaw = $hand | Group | Sort -Property Count -Descending

	#if J, remove from list, add count to biggest entry
	$numberOfJ = $handTypeRaw|where{$_.Name -eq "J"}|select -ExpandProperty Count
	if($handTypeRaw.Length -gt 1 -and $numberOfJ -gt 0){
		$handTypeRaw = @($handTypeRaw| where{$_.Name -ne "J"}| Select -ExpandProperty Count)
		$handTypeRaw[0] += $numberOfJ
	}
	else{
		$handTypeRaw = $handTypeRaw | Select -ExpandProperty Count
	}
	
    $handType = switch (,@($handTypeRaw)) {
        { $_[0] -eq 5 } { 7; Break }
        { $_[0] -eq 4 } { 6; Break }
        { $_[0] -eq 3 -and $_[1] -eq 2 } { 5; Break }
        { $_[0] -eq 3 } { 4; Break }
        { $_[0] -eq 2 -and $_[1] -eq 2 } { 3; Break }
        { $_[0] -eq 2 } { 2; Break }
        Default { 1; Break }
    }

    $str = ("0x$( $_.Substring(0,5) )" -replace 'A', 'E' -replace 'K', 'D' -replace 'Q', 'C' -replace 'J', '1' -replace 'T', 'A')
    $strength = [long]$str

    [PSCustomObject]@{
        hand        = $_.Substring(0, 5);
        bid         = $bid;
        type        = $handType;
        strength    = $strength;
        strengthStr = $str;
    }
}
$data = $data | Sort -Property type, strength 
$data | % { $rank = 1 } { $_.bid * $rank++ } | measure -sum | select -ExpandProperty Sum