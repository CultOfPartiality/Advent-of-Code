. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#function Solution {
#    param ($Path)

$Path = "$PSScriptRoot/input.txt"


$clues =
"children: 3
samoyeds: 2
akitas: 0
vizslas: 0
cars: 2
perfumes: 1"

$clues = $clues | %{$_ -replace ": ","="} | ConvertFrom-StringData
$data = get-content $Path
$data = $data | %{$_ -replace "Sue (\d*): ",'Sue=$1,' -replace ",","`n" -replace ": ","=" | ConvertFrom-StringData}

#cats > 7
$data = $data | where{$_.cats -gt 7 -OR $_.cats -eq $null}
#trees > 3
$data = $data | where{$_.trees -gt 7 -OR $_.trees -eq $null}
#pomeranians < 3
$data = $data | where{$_.pomeranians -lt 3 -OR $_.pomeranians -eq $null}
#goldfish < 5
$data = $data | where{$_.goldfish -lt 5 -OR $_.goldfish -eq $null}


$clues.GetEnumerator() | ForEach-Object{
    $key = $_.Key
    $value = $_.Value
    $data = $data | where{$_."$key" -eq $value -OR $_."$key" -eq $null}
}

#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 1: Sue $($data.Sue)" -ForegroundColor Magenta

