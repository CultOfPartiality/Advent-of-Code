. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"
$totalRows = 40

# $Path = "$PSScriptRoot/testcases/test1.txt"
# $totalRows = 10


#function Solution {
#    param ($Path)

$firstRowRaw = get-content $Path
$rowWidth = $firstRowRaw.Length
$rows = @()
$rows += $firstRowRaw

for ($row = 0; $row -lt $totalRows-1; $row++) {
	$nextRow = ""
	# We add an extra safe tile to the right by shifting left, then move a 3 tile window along the data and check
	$rowAbove = "."+$rows[$row]+"."
	for ($i = 1; $i -lt $rowWidth+1; $i++) {
		$tilesAbove = $rowAbove.Substring($i-1,3)
		$nextRow += $tilesAbove -in ("^^.", ".^^", "^..", "..^") ? "^" : "."
	}
	$rows+=$nextRow
}

$safeTiles = ($rows | %{$_.ToCharArray()} | ?{$_ -eq "."}).Count
write-host "$safeTiles safe tiles"

#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

