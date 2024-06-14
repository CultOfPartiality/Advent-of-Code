. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#function Solution {
#    param ($Path)

#The following line is for development
$volume = 20
$Path = "$PSScriptRoot/testcases/test1.txt"

$data = get-content $Path | %{ [int32] $_ } | sort -Descending


######My plan: get all values -le to the remaining volume to fill
foreach($start in 0..($data.Count-1)){
    $index = $start
    if($start -eq $data.Count-1){continue}
    foreach($)


}



    
#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta

