. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#function Solution {
#    param ($Path)

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

$data = get-content $Path

$blocks = foreach ($line in $data) {
    $start,$end = $line -split '~' | %{,@($_-split ',')}
    [PSCustomObject]@{
        x1 = [int]$start[0]
        y1 = [int]$start[1]
        z1 = [int]$start[2]
        x2 = [int]$end[0]
        y2 = [int]$end[1]
        z2 = [int]$end[2]
    }
}

$landed = New-Object 'object[,,]' 3,3,3
#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta

