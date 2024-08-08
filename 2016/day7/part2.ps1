. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test2.txt"
$Path = "$PSScriptRoot/input.txt"


# function Solution {
#     param ($Path)

    #First limit to only entries with "ABA"
    $data = (get-content $Path) -match "((\w)(\w)(?<!\2)\2)"
    #Match "aba" outside the brackets, and "bab" inside the brackets
    <#The regex has two options: matching [aba]bab or aba[bab]
        1:
            (^|\])|w* - We either start at the start, or just after a [] block, then match all the prececeeding chars that aren't another [] block
            ((\w)(\w)(?<!\3)\3) - Match 2 chars, with a negative lookbehind to make sure they aren't the same, then match another instance of the first char (capture group 3)
            \w*(\[\w*\]\w*)* - Capture just chars, and as many not relevant blocks of []
            (\[\w*(\4\3\4)\w*\]) - Match the matching XYX within a [] block
        2: Same as above in the other order ([] block first), except without the starting restriction as we always start in a [] block
    #>
    $newdata =  ($data -Match '(^|\])\w*((\w)(\w)(?<!\3)\3)\w*(\[\w*\]\w*)*(\[\w*(\4\3\4)\w*\])') + 
                ($data -Match '\[\w*((\w)(\w)(?<!\2)\2)\w*\]\w*(\[\w*\]\w*)*(\3\2\3)')
    
    $newdata.count
    
# }

# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 3
# $result = Solution "$PSScriptRoot\input.txt"
# Write-Host "Part 2: $result" -ForegroundColor Magenta
#190 too low
#232 "wrong"
#242 is right
#272 too high