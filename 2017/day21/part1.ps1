. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

#function Solution {
#    param ($Path)

# Take the input mappings, load the outcomes into an array in order
# Generate each possible permutation of the input, hash it somehow, and toss in hashmap with the value being the index of the 
# ouput array

function Flip-Hoz($pattern){
    $pattern = foreach($row in $pattern){
        $list = [System.Collections.ArrayList]$row
        $list.Reverse()
        ,[array]$list
    }
    $pattern
}

function Rotate-Clock($pattern){
    $side = $pattern.Count-1
    $newPattern = $pattern | %{,$_.clone()}
    for ($i = $side; $i -ge 0; $i--) {
        for ($j = 0; $j -le $side; $j++) {
            $newPattern[$j][$side-$i] = $pattern[$i][$j]
        }
    }
    $newPattern
}

function Hash-Pattern($pattern){
    ($pattern | %{$_ -join ""}) -join ""
}

$outcomes = @()
$inputMapping = @{}
$data = get-content $Path
for ($i = 0; $i -lt $data.Count; $i++) {
    $pattern,$outcome = $data[$i] -split " => "
    $outcomes += $outcome
    $pattern = $pattern -split "/" | %{,$_.ToCharArray()}
    # Flip the starting pattern horizontally, then rotate each three times, yeilding the 8 possible arrangements
    $patternAndFlipped = $pattern,(Flip-Hoz($pattern))
    $allPatterns = $patternAndFlipped | %{
        $pattern = $_
        Hash-Pattern($pattern)
        foreach($rotations in 1..3){
            $pattern = Rotate-Clock($pattern)
            Hash-Pattern($pattern)
        }
    }
    # Add index to each unique key
    $allpatterns | select -Unique | %{
        $inputMapping[$_] = $i
    }
}

$currentPattern = ".#./..#/###"  -split "/" | %{,$_.ToCharArray()}

for ($round = 0; $round -lt 5; $round++) {
    write-host "Round $($round+1)"
    # Prep new array
    $oldGroupSize = ($currentPattern.Count % 3 -eq 0) ? 3 : 2
    $newGroupSize = ($currentPattern.Count / $oldGroupSize)*($oldGroupSize+1)
    $newPattern = New-Object "object[]" $newGroupSize
    foreach($rowNum in 0..($newSideSize-1)){
        $newPattern[$rowNum] = New-Object "char[]" $newGroupSize
    }

    # Loop over subgroups of currentPattern, perform the lookup, then allocate to newPattern's subgroup
    for ($subRow = 0; $subRow -lt ($currentPattern.Count/$oldGroupSize) ; $subRow++) {
        for ($subCol = 0; $subCol -lt ($currentPattern.Count/$oldGroupSize); $subCol++) {
            write-host "Row $subRow, col $subCol = "
            # TODO: Generate sub array
            # TODO: Do the hash and lookup
            # TODO: Insert into newPattern
        }
    }
    $currentPattern = $newPattern
}

#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

