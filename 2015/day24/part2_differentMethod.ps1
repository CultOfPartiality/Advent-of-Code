. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#function Solution {
#    param ($Path)

#The following line is for development
# $Path = "$PSScriptRoot/testcases/test1.txt"
# $Path = "$PSScriptRoot/testcases/test2.txt"
$Path = "$PSScriptRoot/input.txt"

$rawdata = get-content $Path
$data = $rawdata | %{ [int32] $_ } | sort -Descending

$quarterOfTotal = ( $rawdata | %{[int]$_} | measure -sum |select -ExpandProperty sum ) / 4
write-host "Groups of $quarterOfTotal"
if( $quarterOfTotal % 1 -gt 0){
    exit
}

#Start by finding possible sums to the third of the total (See day 17, bruteforce for comments to below)
# Take 2: Start looking for groups that are 1 long, then 2 long, then 3 long...
# As each point we find all valid combos, check their validity then. If none valid, got to the biggest (smallest) group length
function get-all-groups-x-long{
	param($data,$desiredTotal,$desiredLength)
	
	$foundperms = @()
	$possibleQueue = New-object -TypeName System.Collections.Stack
	for ($i = $data.Count-1; $i -ge 0; $i--) {
		$possibleQueue.Push(@(,$i))
	}
	while ($possibleQueue.Count){
		$currentIndexes = $possibleQueue.Pop()
		$total = $currentIndexes | %{$data[$_]} | measure -Sum | select -ExpandProperty Sum
		for ($i = $currentIndexes[-1]+1; $i -lt $data.Count; $i++) {
			if($total+$data[$i] -lt $desiredTotal -and (($currentIndexes.count+1) -le ($desiredLength-1))){
				$possibleQueue.Push( $currentIndexes + $i)
			}
			elseif($total+$data[$i] -eq $desiredTotal -and (($currentIndexes.count+1) -eq $desiredLength)){
				$foundperms += ,($currentIndexes+$i)
			}
		}
	}
	$foundperms
}



#Run length 1, if no results length 2, and so on
$perms = @()
$length = 0
while($perms.count -eq 0){
	#get the initial perms
    $length++
	$perms = get-all-groups-x-long $data $quarterOfTotal $length
    write-host "$($perms.count) possible first blocks found of length $length... "
	
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
        write-host "`tChecking $($perm) for a second valid block"

        $remainingData = 0..($data.count-1) | ?{$_ -notin $perm.perm} | %{ $data[$_]}
        $secondValidPerm = @()
        for($secondValidPermLen = 1; $secondValidPermLen -lt $remainingData.count; $secondValidPermLen++){
            $secondValidPerm = get-all-groups-x-long $remainingData $quarterOfTotal $secondValidPermLen
            write-host "`t`t$($secondValidPerm.count) possible second blocks found of length $secondValidPermLen... "
            
            foreach($secondPerm in $secondValidPerm){
                write-host "`t`t`tChecking $($perm) for a third valid block"
                $secondRemainingData = $remainingData = 0..($data.count-1) | ?{$_ -notin $perm.perm} | ?{$_ -notin $secondPerm} | %{ $data[$_]}
                $finalValidPerm = @()
                for ($finalValidPermLen = 1; $finalValidPermLen -lt $secondRemainingData.Count; $finalValidPermLen++) {
                    $finalValidPerm = get-all-groups-x-long $secondRemainingData $quarterOfTotal $finalValidPermLen
                    
                    if($finalValidPerm.count -gt 0){
                        write-host "Best valid perm found:"
                        $perm
                        exit
                    }
                }

            }
        }


    }
    write-host "$($perms.count) were valid"
}

#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta

