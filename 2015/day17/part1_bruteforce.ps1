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

$perms = @()


#Setup queue
$possibleQueue = New-object -TypeName System.Collections.Queue
#Add each index in main data to an array, and into the queue
for ($i = 0; $i -lt $data.Count; $i++) {
    $possibleQueue.Enqueue(@(,$i))
}

#While the queue is not empty:
#Loop over next numbers in the data after the currently used indexes from the queue
#Where a number added to the running total is less than the final total, add those indexes back to the queue
#If equal to the final total, add to the perms array and discard
while ($possibleQueue.Count){
    $currentIndexes = $possibleQueue.Dequeue()
    $total = $currentIndexes | %{$data[$_].value} | measure -Sum | select -ExpandProperty Sum
    for ($i = $currentIndexes[-1]+1; $i -lt $data.Count; $i++) {
        if($total+$data[$i].value -lt $volume){
            $possibleQueue.Enqueue( $currentIndexes + $i)
        }
        elseif($total+$data[$i].value -eq $volume){
            $perms += ,($currentIndexes+$i)
        }
    }
}

$perms | %{write-host $_}
Write-Host "Part 1 - Total permutations: $($perms.Count)" -ForegroundColor Magenta

$minCountainerCount = $perms | %{$_.count} | measure -Minimum | select -ExpandProperty Minimum
$countOfMins = ($perms | where {$_.count -eq $minCountainerCount}).count

Write-Host "Part 2 - Minimum container count ($minCountainerCount), $countOfMins perms" -ForegroundColor Magenta


#Not 27

#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta

