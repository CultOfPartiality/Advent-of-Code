
param(
    [string]$foldername
)

# If path is just a year, then generate the next day
if($foldername -match '^20\d\d$'){
    $max = Get-ChildItem -Path "./$foldername/" -Directory | %{[int]$_.Name.TrimStart("day")} | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
    $foldername+="/day$($max+1)"
}

# Check to make sure directory doesn't already exist
if(test-path "./$foldername"){
    Write-Host "Path already exists" -ForegroundColor Red
    exit
}

# If path is just a year, then generate the next day
if($foldername -match '^20\d\d$'){
    Get-ChildItem -Path "./$foldername/" -Directory

    exit
}

New-Item -Path "./$foldername" -ItemType Directory
New-item -Path "./$foldername/part1.ps1"
New-item -Path "./$foldername/input.txt"
New-Item -Path "./$foldername/testcases" -ItemType Directory
New-Item -Path "./$foldername/testcases/test1.txt"


$template = @'
. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

#function Solution {
#    param ($Path)


$data = get-content $Path

<#WRITE CODE HERE, TEST, THEN PUT IN FUNCTION #>
    
#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

'@

Out-File -FilePath "./$foldername/part1.ps1" -InputObject $template


# Open new files in VSCode
code --reuse-window "./$foldername/testcases/test1.txt" "./$foldername/input.txt" "./$foldername/part1.ps1"

