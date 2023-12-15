. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
	param ($Path)

#parse data, remove each trailing full stop and splitting into words
$data = Get-Content $Path | %{,@($_.Substring(0,$_.Length-1).Split(" "))}

#build up a happiness hash
$happinessHash = @{}
$data | %{
	$firstPerson = $_[0]
	$secondPerson = $_[-1]
	$happiness = $_[2] -eq 'gain' ? [int]$_[3] : -$_[3]
	$happinessHash.Add("$firstPerson,$secondPerson",$happiness)
}

#get the people
$people = $data | %{$_[0]} | select -Unique

#generate all possible combos
$seatingOrders = Get-AllPermutations $people

#for each seating order, calculate the happiness score
$possibleHappinesses = $seatingOrders | %{
	$order = $_
	$totalHappiness = 0
	for ($personIndex = 0; $personIndex -lt $order.Count; $personIndex++) {
		$prevPersonIndex = $personIndex-1
		$nextPersonIndex = $personIndex -eq $order.Count-1 ? 0 : $personIndex+1
		$totalHappiness+=$happinessHash[$order[$personIndex]+","+$order[$prevPersonIndex]]
		$totalHappiness+=$happinessHash[$order[$personIndex]+","+$order[$nextPersonIndex]]
	}
	$totalHappiness
}

#output the max happiness
$possibleHappinesses| measure -Maximum | select -ExpandProperty Maximum

}

Unit-Test  ${function:Solution} "$PSScriptRoot\test.txt" 330
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Solution: $result" -ForegroundColor Magenta