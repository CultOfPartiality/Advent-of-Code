. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#function Solution {
#    param ($Path)

#The following line is for development
#$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/testcases/test2.txt"
# $Path = "$PSScriptRoot/input.txt"

$rawdata = get-content $Path
$data = $rawdata | %{ [int32] $_ } | sort -Descending

$thirdOfTotal = ( $rawdata | %{[int]$_} | measure -sum |select -ExpandProperty sum ) / 3
write-host "Groups of $thirdOfTotal"


#Start by finding possible sums to the third of the total (See day 17, bruteforce for comments to below)
# Take 2: Start looking for groups that are 1 long, then 2 long, then 3 long...
# As each point we find all valid combos, check their validity then. If none valid, got to the biggest (smallest) group length
function get-all-groups-x-long{
	param($data,$desiredTotal,$desiredLength)
	
	$perms = @()
	$possibleQueue = New-object -TypeName System.Collections.Stack
	for ($i = $data.Count-1; $i -ge 0; $i--) {
		$possibleQueue.Push(@(,$i))
	}
	while ($possibleQueue.Count){
		$currentIndexes = $possibleQueue.Pop()
		$total = $currentIndexes | %{$data[$_]} | measure -Sum | select -ExpandProperty Sum
		for ($i = $currentIndexes[-1]+1; $i -lt $data.Count; $i++) {
			if($total+$data[$i] -lt $thirdOfTotal -and ($currentIndexes.count -lt ($desiredLength-1))){
				$possibleQueue.Push( $currentIndexes + $i)
			}
			elseif($total+$data[$i] -eq $thirdOfTotal){
				$perms += ,($currentIndexes+$i)
			}
		}
	}
	$perms
}

#Run length 1, if no results length 2, and so on
$perms = @()
$length = 0
while($perms.count -eq 0){
	#get the initial perms
    $length++
	$perms = get-all-groups-x-long $data $thirdOfTotal $length
    write-host "$($perms.count) possible first groups found of length $length... " -NoNewline
	
	#Sort by QE, and we'll check the best ones first
	$perms = foreach($perm in $perms){
		$qe = 1; ($perm | %{ $qe *= $data[$_] })
		[PSCustomObject]@{
			perm = $perm
			values = ($perm | %{ $data[$_]})
			qe = $qe
		}
	}
	$perms = $perms | sort -Property {$_.qe}
    
	#check those perms are valid, by generating the next set/s
    $perms = foreach($perm in $perms){

        $remainingData = 0..($data.count-1) | ?{$_ -notin $perm.perm} | %{ $data[$_]}
        $anotherValidPerm = @()
        $anotherValidPermLength = 0
        for($i = 0; $i -lt $remainingData.count; $i++){
            $anotherValidPermLength++
            $anotherValidPerm = get-all-groups-x-long $remainingData $thirdOfTotal $anotherValidPermLength
            if($anotherValidPerm.count -gt 0){
				write-host "Best valid perm found:"
                $perm
                exit
            }
        }


    }
    write-host "$($perms.count) were valid"
}

#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta

