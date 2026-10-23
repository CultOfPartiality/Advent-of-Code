. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

#function Solution {
#    param ($Path)

[int[]]$adaptors = get-content $Path

<#WRITE CODE HERE, TEST, THEN PUT IN FUNCTION #>
   
#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 35
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 220
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

