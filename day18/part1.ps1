. "$PSScriptRoot\..\Unit-Test.ps1"
. "$PSScriptRoot\..\UsefulStuff.ps1"

#function Solution {
#    param ($Path)

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

$data = get-content $Path

<#WRITE CODE HERE, THEN #>
    
#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta

