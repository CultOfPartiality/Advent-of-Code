. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"


function Solution {
    param ($Path)


    #First remove all strings with "...[...xyyx...]..." (with a negatie lookbehind to endure the second match isn't the same as the first ), 
    #then include all that still have "xyyx"
    $data = (get-content $Path) -NotMatch '\[\w*((\w)(\w)(?<!\2)\3\2)\w*\]' -Match '(\w)(\w)(?<!\1)\2\1'
    $data.count
    
}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 2
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 1: $result" -ForegroundColor Magenta
