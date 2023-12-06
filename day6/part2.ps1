#Get input
#$inputSource = "$PSScriptRoot/example.txt"
$inputSource = "$PSScriptRoot/input.txt"


$time,$record = Get-Content $inputSource | Select-String '\d+' -AllMatches | %{ [long] (($_.Matches.Value) -join "")}

$min0 = [math]::Floor(($time - [math]::Sqrt($time*$time-4*$record))/2) +1
$max0 = [math]::Ceiling(($time + [math]::Sqrt( $time*$time-4*$record ))/2) -1

$wins = $max0 - $min0 + 1
"Part 2: $wins"

# for ($i = 0; $i -lt $times.Count; $i++) {
#     $time = $times[$i]
#     $record = $records[$i]

#     $wins =  0..$time | %{$_*$time - $_*$_} | where {$_ -gt $record} | measure | select -ExpandProperty Count

#     $counts = $counts ? $counts * $wins : $wins
# }
