. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#function Solution {
#    param ($Path)

$data = 33100000

#loose upper bound: elf 3310000 delivers the full about to house 3310000

# $lcm = 1
# $inputs = ""
# $presents = 0
# 1..100 | %{
# 	$inputs += "$_,"
# 	$presents += 10*$_
# 	$lcm = lcm $_ $lcm
# }

# write-host "LCM of $($inputs.TrimEnd("+")): $lcm"
# write-host "I.e. house $lcm has $presents presents"

function How-ManyPresents{
	param ( $houseNum)
	$presents = (1..([Math]::Floor([Math]::Sqrt($houseNum))) | %{ if($houseNum % $_ -eq 0){ ($_,($houseNum/$_))}} | sort | unique | measure -Sum | select -ExpandProperty Sum)
	$presents * 10
}


750000..776160 | %{
	$houseNum = $_
	#work out factors, sum up and multiply by 10
	$presents = How-ManyPresents $houseNum
	if($presents -ge $data){
		write-host "House $houseNum gets $presents presents"
	 	exit
	}
}

#TOO HIGH
#	786240
#BRUTEFORCE
# 	776160  ✔

#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta

