
param(
    [string]$foldername
)

New-Item -Path "./$foldername" -ItemType Directory
New-item -Path "./$foldername/part1.ps1"
New-item -Path "./$foldername/input.txt"
New-Item -Path "./$foldername/testcases" -ItemType Directory
New-Item -Path "./$foldername/testcases/test1.txt"


$template = @'
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

'@

Out-File -FilePath "./$foldername/part1.ps1" -InputObject $template