. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

#function Solution {
#    param ($Path)


$data = get-content $Path | %{
	$start,$end = $_ -split "-"
	[PSCustomObject]@{
		start = [uint]$start
		end = [uint]$end
	}
} | sort {$_.start}

$LowestValidAddress = 0
for ($i = 0; $i -lt $data.Count; $i++) {
	$range = $data[$i]
	if($range.start -le $LowestValidAddress -and $range.end -ge $LowestValidAddress){
		$LowestValidAddress = $range.end+1
	}
}
Write-Host "Part 1: $LowestValidAddress" -ForegroundColor Magenta


# Part 2
$LowestValidAddress = 0
$ValidAddressCount = 0
for ($i = 0; $i -lt $data.Count; $i++) {
	$range = $data[$i]
	if($range.start -le $LowestValidAddress -and $range.end -ge $LowestValidAddress){
		$LowestValidAddress = $range.end+1
	}
	elseif($range.start -gt $LowestValidAddress){
		$ValidAddressCount += $range.start - $LowestValidAddress
		$LowestValidAddress = $range.end+1
	}
}
Write-Host "Part 2: $ValidAddressCount" -ForegroundColor Magenta
#960859545 too high 9:26


#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}

