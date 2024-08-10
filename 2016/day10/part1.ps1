. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

#function Solution {
#    param ($Path)


$data = get-content $Path | %{,@(($_ -split " "))}


$inputs = $data | ?{$_[0] -eq "value"}
$maxBot = $data | %{[int]$_[-1]} | measure -Maximum | select -ExpandProperty Maximum


#This looks like we're building a tree


#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

