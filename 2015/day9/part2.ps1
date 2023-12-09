function Get-AllPermutations {
	param ($array)

	$a = $array

	$b = $a|%{,@($_)}

	while($b[0].Count -lt $a.Count){
		$b = $b|%{
			$current = $_
			$valuesLeft = $a|?{$current -notcontains $_}
			$valuesLeft | %{
				,@($current+$_)
			}
		}
	}
	$b
}

function day9Part1 {
	param ($inputSource)
	$input = Get-Content $inputSource

	#get all sites
	$sites = $input | %{$_ | Select-String "[a-zA-Z]{5,}" -AllMatches } | select -ExpandProperty Matches| select -ExpandProperty Value -Unique

	#generate hash of all distances
	$distancesHash = @{}
	$input | %{
		$split = $_ -split " "
		$distancesHash."$($split[0])2$($split[2])" = [int]$split[4]
		$distancesHash."$($split[2])2$($split[0])" = [int]$split[4]
	}

	#it's only 8!, so generate all possabilties and calculate dist
	$possabilities = Get-AllPermutations $sites
	$result = $possabilities | %{
		$distance = 0
		for ($i = 1; $i -lt $_.Count; $i++) {
			$distanceIndex = $_[$i-1]+"2"+$_[$i]
			$distance+=$distancesHash[$distanceIndex]
		}
		$distance
	} | measure -Maximum | select -ExpandProperty Maximum

	#return
	$result
}

$part1Example = day9Part1 "$PSScriptRoot/example.txt"
if($part1Example -eq 982){
	write-host "Example passed ✔ " -ForegroundColor Green
}
else{
	write-host "Example failed ✖ " -ForegroundColor Red
	Write-host "Was: $part1example. Expected: 982" -ForegroundColor Red
	exit
}

$part1 = day9Part1 "$PSScriptRoot/input.txt"
write-host "Answer for part 1: $part1" -ForegroundColor Magenta
