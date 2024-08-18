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
#convert to binary string, then hex string, then to big int
$firstRowBinString = $firstRowRaw.replace("^","1").Replace(".","0")
$firstRowHexString = ""

for($i=0; $i -lt $firstRowBinString.Length; $i+=8){
	$bytes = $firstRowBinString[-($i+8)..-($i+1)] -join ""
	$hex = [convert]::ToInt16($bytes,2).ToString('X').PadLeft(2,"0")
	$firstRowHexString = $hex+$firstRowHexString
}
$rows += [bigint]::Parse($firstRowHexString,"AllowHexSpecifier")

for ($row = 0; $row -lt $totalRows-1; $row++) {
	$nextRow = [bigint]0
	# We add an extra safe tile to the right by shifting left, then move a 3 tile window along the data and check
	$rowAbove = $rows[$row]*2
	for ($i = 0; $i -lt $firstRowBinString; $i++) {
		$tilesAbove = ($rowAbove -band (0b111 -shl $i)) -shr $i
		$nextRow += $tilesAbove -in (0b110, 0b011, 0b100, 0b001) ? 1 -shl $i : 0
	}
	$rows+=$nextRow
}

$safeTiles = ($rows | %{$_.ToCharArray()} | ?{$_ -eq "."}).Count
write-host "$safeTiles safe tiles"

#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

