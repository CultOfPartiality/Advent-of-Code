. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
	param ($Path)

	#parse data, remove each trailing full stop and splitting into words
	$data = Get-Content $Path | % { , @($_.Substring(0, $_.Length - 1).Split(" ")) }

	#build up a happiness hash
	$happinessHash = @{}
	$data | % {
		$firstPerson = $_[0]
		$secondPerson = $_[-1]
		$happiness = $_[2] -eq 'gain' ? [int]$_[3] : - $_[3]
		$happinessHash.Add("$firstPerson,$secondPerson", $happiness)
	}

	#get the people
	$people = $data | % { $_[0] } | select -Unique

	#generate all possible combos
	$seatingOrders = Get-AllPermutations $people

	#for each seating order, calculate the happiness score, but this time do the corners and output array
	$possibleHappinesses = $seatingOrders | % {
		$order = $_
		$totalHappiness = @()
		for ($personIndex = 0; $personIndex -lt $order.Count; $personIndex++) {
			$prevPersonIndex = $personIndex - 1
			$totalHappiness += $happinessHash[$order[$personIndex] + "," + $order[$prevPersonIndex]] +
			$happinessHash[$order[$prevPersonIndex] + "," + $order[$personIndex]]
		}
		, @($totalHappiness)
	}

	#output the max happiness, removing the worst possibility to simulate you sitting between
	$happinessesWithYOU = $possibleHappinesses | % { ($_ | sort)[1..($_.Count - 1)] | measure -Sum | select -ExpandProperty Sum }
	$happinessesWithYOU | measure -Maximum | select -ExpandProperty Maximum

}

#Unit-Test  ${function:Solution} "$PSScriptRoot\test.txt" 330
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Solution: $result" -ForegroundColor Magenta