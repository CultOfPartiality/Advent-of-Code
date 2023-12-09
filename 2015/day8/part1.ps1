$inputSource = "$PSScriptRoot/input.txt"

$input = Get-Content $inputSource

$memTotal = $input | %{ $_.Length } | measure -sum | select -ExpandProperty Sum

$strTotal = $input | %{
	($_ -replace "\\\\","_" -replace '\\"',"_" -replace "\\x..","_").Length - 2
} | measure -sum | select -ExpandProperty Sum

Write-Host "$memTotal in memory, $strTotal in actual string, difference: $($memTotal-$strTotal)"

#part 2

$encodeTotal = $input | %{
	($_ -replace '\\','\\' -replace '"','\"').Length + 2
} | measure -sum | select -ExpandProperty Sum

Write-Host "$memTotal in memory (still), $encodeTotal in newly encoded string, difference: $($encodeTotal-$memTotal)"
