. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"


function Solution {
   param ($Path)


$data = get-content $Path

$mostLikely = for($i = 0; $i -lt $data[0].Length; $i++){
    $data | %{ $_.substring($i,1) } | group | sort Count | select -expandProperty name -First 1
}

$mostLikely -join ""
}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" "advent"
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 2: $result" -ForegroundColor Magenta
