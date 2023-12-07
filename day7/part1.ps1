#Get input
#$inputSource = "$PSScriptRoot/example.txt"
$inputSource = "$PSScriptRoot/input.txt"

Get-Content $inputSource | % {
    $hand = ([char[]]$_)[0..4]
    $bid = [int] [Regex]::Match($_, ' \d+').Value
    $handType = switch (,@($hand | Group | Select -ExpandProperty Count | Sort -Descending)) {
        { $_[0] -eq 5 } { 7; Break }
        { $_[0] -eq 4 } { 6; Break }
        { $_[0] -eq 3 -and $_[1] -eq 2 } { 5; Break }
        { $_[0] -eq 3 } { 4; Break }
        { $_[0] -eq 2 -and $_[1] -eq 2 } { 3; Break }
        { $_[0] -eq 2 } { 2; Break }
        Default { 1; Break }
    }

    $str = ("0x$( $_.Substring(0,5) )" -replace 'A', 'E' -replace 'K', 'D' -replace 'Q', 'C' -replace 'J', 'B' -replace 'T', 'A')
    $strength = [long]$str

    [PSCustomObject]@{
        hand        = $_.Substring(0, 5);
        bid         = $bid;
        type        = $handType;
        strength    = $strength;
        strengthStr = $str;
    }
} | Sort -Property type, strength | % { $rank = 1 } { $_.bid * $rank++ } | measure -sum | select -ExpandProperty Sum