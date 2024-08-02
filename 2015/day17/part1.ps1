. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#function Solution {
#    param ($Path)

#The following line is for development
# $volume = 25
# $Path = "$PSScriptRoot/testcases/test1.txt"

# $volume = 27
# $Path = "$PSScriptRoot/testcases/test2.txt"

$volume = 150
$Path = "$PSScriptRoot/input.txt"

$rawdata = get-content $Path
$dups = $rawdata | %{[int32]$_} | Group-Object | where {$_.Count -gt 1} | select -ExpandProperty name
$data = $rawdata | %{ 
    [PSCustomObject]@{
        value  = [int32] $_
        used   = $false
        dup    = ([int32] $_ -in $dups)
    } } | sort -Property value -Descending


$options = @()

######My plan: get all values -le to the remaining volume to fill
while ($data.count -gt 1) {
    $testArray = $data | %{$_.used = $false;$_}
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
                
                #If a single value of a duplicate was used, add second permutations.
                #If two unique dupes, add 4
                #Otherwise, just 1
                $duplicateOptions = $testArray | where used | where dup | group value | where count -eq 1
                if($duplicateOptions.Count -gt 0){
                    Write-Host $equation.TrimEnd("+") " ("($duplicateOptions.Count * 2)" permutations)"
                }
                else{
                    Write-Host $equation.TrimEnd("+")
                }
                $options+=[PSCustomObject]@{
                    equation  = $equation.TrimEnd("+")
                    dupCount  = $duplicateOptions.Count
                }
                
                break
            }
        }
        #remove the last 'used' element, and reset used 
        $testArray = $testArray | Where-Object {$_ -ne (($testArray | where used)[-1])}
        $testArray = $testArray | %{$_.used = $false;$_}
    }
    $data = $data | select -skip 1
}

#get unique
$uniqueOptions = $options | sort equation | get-Unique -asstring
#add extra perms for where 36 included, but not 18

$perms = ($uniqueOptions | %{
    if( ($_.equation -match "36") -and ($_.equation -notmatch "18")){
        2*[Math]::Max(($_.dupCount*2),1)
    }
    else{
        [Math]::Max(($_.dupCount*2),1)
    }
} | Measure-Object -Sum).Sum


Write-Host "Total permutations: $perms" -ForegroundColor Magenta
#Not 27, 39, 41

#Missing (at least) 46+36+32+18+18

#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta

