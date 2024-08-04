. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#function Solution {
#    param ($Path)

#The following line is for development
#$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/input.txt"

$rawdata = get-content $Path
$data = $rawdata | %{ [int32] $_ } | sort -Descending

$thirdOfTotal = ( $rawdata | %{[int]$_} | measure -sum |select -ExpandProperty sum ) / 3
write-host "Groups of $thirdOfTotal"


#Start by finding possible sums to the third of the total (See day 17, bruteforce for comments to below)
$perms = @()
$possibleQueue = New-object -TypeName System.Collections.Stack
for ($i = $data.Count-1; $i -ge 0; $i--) {
    $possibleQueue.Push(@(,$i))
}
while ($possibleQueue.Count){
    $currentIndexes = $possibleQueue.Pop()
    $total = $currentIndexes | %{$data[$_]} | measure -Sum | select -ExpandProperty Sum
    for ($i = $currentIndexes[-1]+1; $i -lt $data.Count; $i++) {
        if($total+$data[$i] -lt $thirdOfTotal){
            $possibleQueue.Push( $currentIndexes + $i)
        }
        elseif($total+$data[$i] -eq $thirdOfTotal){
            $perms += ,($currentIndexes+$i)
        }
    }
}
write-host "$($perms.count) possible first groups found"

#Then work out if the remaining numbers can be split into two groups of the same total
#Get all unique pairs, where the arrays don't share any numbers (or in this case, indexes), and combine into a single array
#Then if a potential grouping has no matching numbers in common with an array, it's a viable solution

#function Get-AllPairs from "usefulstuff", but modified
function arraysDontShareElements{
	param( $array1, $array2)
	($array1 | ? {$array2 -contains $_}).count -eq 0
}

$a = @()+$perms
$uniqueOtherSets = $perms | % {
	$current = $_
	$a = $a | ? { arraysDontShareElements $current $_ }
	$a | % { , @($current,$_) }
}

write-host "$($uniqueOtherSets.count) possible other sets found"

$validPerms = foreach($perm in $perms){	
	$possibleSets = $uniqueOtherSets | %{
		if(arraysDontShareElements $perm $_){
			$_
		}
	}
	if($possibleSets.count -gt 0){
		$qe = 1
		$perm | %{ $qe *= $data[$_] }
		[PSCustomObject]@{
			perm = $perm
			qe = $qe
		}
	}
}

write-host "$($validPerms.count) possible valid groupings found"

$validPerms = $validPerms | sort -Property {$_.perm.Count},{$_.qe}
Write-Host "Part 1 - Best Quantum Entanglement of the smallest size group/s: $($validPerms[0].qe)" -ForegroundColor Magenta


#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta

