. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
# $Path = "$PSScriptRoot/input.txt"

#function Solution {
#    param ($Path)

get-content $Path | Split-Array -GroupSize 4 | ? { $_[0] -match "Before:" } | % {	 
	[int[]] $beforeRegisters = $_[0].TrimStart("Before: [").TrimEnd("]") -split ", "
	[int[]] $op = $_[1] -split " "
	[int[]] $afterRegisters = $_[2].TrimStart("After: [").TrimEnd("]") -split ", "

	
}



#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

