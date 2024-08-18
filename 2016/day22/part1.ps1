. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

#function Solution {
#    param ($Path)


$data = get-content $Path | select -Skip 2
$uid = 0
$nodes = $data | % {
	$parts = $_ -split "\s+"
	[PSCustomObject]@{
		Name   = $parts[0]
		UID	 = $uid++
		Size   = [int]$parts[1].TrimEnd("T")
		Used   = [int]$parts[2].TrimEnd("T")
		Avail  = [int]$parts[3].TrimEnd("T")
		UsePer = ( [int]$parts[4].TrimEnd("%") ) / 100.0
	}
}

$viablePairs=0
foreach($node1 in $nodes){
	if($node1.Used -eq 0){continue}
	foreach($node2 in $nodes){
		if($node1.UID -ne $node2.UID -and
		$node1.Used -le $node2.Avail  ){
			$viablePairs++
		}
	}
}
write-host "Part 1: Ther are $viablePairs viable pairings of nodes" -ForegroundColor Magenta
#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

