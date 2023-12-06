#Get input
#$inputSource = "$PSScriptRoot/example.txt"
$inputSource = "$PSScriptRoot/input.txt"


$times,$records = Get-Content $inputSource | Select-String '\d+' -AllMatches | %{ ,@($_.Matches.Value) }

$counts = @()
for ($i = 0; $i -lt $times.Count; $i++) {
    $time = $times[$i]
    $record = $records[$i]

    $wins =  0..$time | %{$_*$time - $_*$_} | where {$_ -gt $record} | measure | select -ExpandProperty Count

    $counts = $counts ? $counts * $wins : $wins
}

"Part 1: $counts"