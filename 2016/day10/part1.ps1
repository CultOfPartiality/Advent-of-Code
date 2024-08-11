. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/input.txt"

#function Solution {
#    param ($Path)


$data = get-content $Path | % { , @(($_ -split " ")) }


$inputs = $data | ? { $_[0] -eq "value" }
$transfers = $data | ? { $_[0] -eq "bot" }
$maxBot = $data | % { [int]$_[-1] } | measure -Maximum | select -ExpandProperty Maximum

#This looks like we're building a tree. We could do this with object links, or array indexes... Lets try indexes, for no real reason
#Start by building the array of bots
$bots = 0..$maxBot | % {
	[PSCustomObject]@{
		botNum      = $_
		chips       = @()
		highGoesTo  = [PSCustomObject]@{
			Type  = ""
			Index = -1
		}
		lowGoesTo   = [PSCustomObject]@{
			Type  = ""
			Index = -1
		}
	}
}
$outputs = 0..$maxBot | % {
	-1
}

foreach ($line in $inputs) {
	$bot = $bots[$line[5]]
	$chipValue = [int]$line[1]
	$bot.chips += $chipValue
}
foreach ($line in $transfers) {
	$bot = $bots[$line[1]]
	$bot.lowGoesTo.Type = $line[5]
	$bot.lowGoesTo.Index = [int]$line[6]
	$bot.highGoesTo.Type = $line[10]
	$bot.highGoesTo.Index = [int]$line[11]
}
$bots | format-table

function calcBot{
	param($index)
	$bot = $bots[$index]
	$bot
	if ($bot.highGoesTo.Type -eq "bot") {
		$newBot = $bots[$bot.highGoesTo.index]
		$newBot.chips += ($bot.chips | sort)[1]
		if($newBot.chips.Count -eq 2){
			calcBot $newBot.botNum
		}
	}
	else {
		$outputs[$bot.highGoesTo.index] = ($bot.chips | sort)[1]	
	}
	if ($bot.lowGoesTo.Type -eq "bot") {
		$newBot = $bots[$bot.lowGoesTo.index]
		$newBot.chips += ($bot.chips | sort)[0]
		if($newBot.chips.Count -eq 2){
			calcBot $newBot.botNum
		}
	}
	else {
		$outputs[$bot.lowGoesTo.index] = ($bot.chips | sort)[0]	
	}

}

$initialCompleteBots = $bots | ? {($_.chips.Count -eq 2) }
$initialCompleteBots | % { 
	calcBot $_.botNum
}


$bots | format-table

$resultBot = $bots | ?{ $_.chips -contains 61} | ?{ $_.chips -contains 17}
#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
Write-Host "Part 1: Bot $($resultBot.botNum) compares 61 and 17" -ForegroundColor Magenta

