. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#function Solution {
#    param ($Path)

#The following line is for development
# $volume = 25
# $Path = "$PSScriptRoot/testcases/test1.txt"

$volume = 27
$Path = "$PSScriptRoot/testcases/test2.txt"

# $volume = 150
# $Path = "$PSScriptRoot/input.txt"

$data = get-content $Path | %{ 
    [PSCustomObject]@{
        value  = [int32] $_
        used   = $false
    } } | sort -Property value

$options = 0

######My plan: get all values -le to the remaining volume to fill
while ($data.count -gt 1) {
    $testArray = $data
    #Loop over remaining sub array, add elements until reaching the total, then remove the biggest used element and go again
    #If only one used (the start) then we're done with this subarray and can remove the starting element from the main data
    while($testArray.count -gt 0){
        $total = 0
        $equation = ''
        foreach($element in $testArray){
            if($total+$element.value -le $volume){
                $total+=$element.value
                $element.used = $true
                $equation+= [string]$element.value + '+'
            }
            if($total -eq $volume){
                $options++
                Write-Host $equation.TrimEnd("+")
                break
            }
        }
        #remove the last 'used' element
        $testArray = $testArray | select -SkipIndex (($testArray | where used).count-1)
    }
    $data = $data | select -skip 1
}

Write-Host "Total permutations: $options" -ForegroundColor Magenta
#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta

