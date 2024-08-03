. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#function Solution {
#    param ($Path)

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

$data = get-content $Path | Select-String "\d+" | %{$_.Matches.Value}
$boss = [PSCustomObject]@{
	Health = $data[0]
	Damage = $data[1]
	Defence = $data[2]
}

<#WRITE CODE HERE, TEST, THEN PUT IN FUNCTION #>

<#		Health	Attack	Defence
Player	8		5		5
Boss	12		7		2	#>
# $playerwins = 12/(5-2) -le 8/(7-5)

$Weapons = (
	[PSCustomObject]@{Cost = 8;Damage = 4},
	[PSCustomObject]@{Cost = 10;Damage = 5},
	[PSCustomObject]@{Cost = 25;Damage = 6},
	[PSCustomObject]@{Cost = 40;Damage = 7},
	[PSCustomObject]@{Cost = 74;Damage = 8}
)
$Armours = (
	[PSCustomObject]@{Cost = 0; Defence = 0},
	[PSCustomObject]@{Cost = 13;Defence = 1},
	[PSCustomObject]@{Cost = 31;Defence = 2},
	[PSCustomObject]@{Cost = 53;Defence = 3},
	[PSCustomObject]@{Cost = 75;Defence = 4},
	[PSCustomObject]@{Cost = 102;Defence = 5}
)
$Rings = (
	[PSCustomObject]@{Cost = 25;  Defence = 0; Damage = 1},
	[PSCustomObject]@{Cost = 50;  Defence = 0; Damage = 2},
	[PSCustomObject]@{Cost = 100; Defence = 0; Damage = 3},
	[PSCustomObject]@{Cost = 20;  Defence = 1; Damage = 0},
	[PSCustomObject]@{Cost = 40;  Defence = 2; Damage = 0},
	[PSCustomObject]@{Cost = 80;  Defence = 3; Damage = 0}
)
Get-AllPairs $Rings | %{
	$Rings += [PSCustomObject]@{
		Cost = $_[0].Cost + $_[1].Cost
		Defence = $_[0].Defence + $_[1].Defence
		Damage = $_[0].Damage + $_[1].Damage
	}
}
$Rings += [PSCustomObject]@{Cost = 0;  Defence = 0; Damage = 0}


function playerWin{
	param($player, $boss)
	[Math]::Ceiling($boss.Health/([Math]::Max($player.Damage-$boss.Defence,1))) -le [Math]::Ceiling($player.Health/([Math]::Max($boss.Damage-$player.Defence,1)))
}


$costs = foreach($Weapon in $Weapons){
	foreach($Armour in $Armours){
		foreach($Ring in $Rings){
			$player = [PSCustomObject]@{
				Health 	= 100
				Damage 	= ($Weapon.Damage + $Ring.Damage)
				Defence = ($Armour.Defence + $Ring.Defence)
				Cost 	= ($Weapon.Cost + $Armour.Cost + $Ring.Cost)
			}

			if(playerWin -player $player -boss $boss){
				$player.Cost
			}

		}
	}
}

$costs | measure -Minimum
#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta
