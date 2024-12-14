. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"


function Solution {
	param ($Path)

	# Parse the bots, calculate where they'll be in 100s using modulo arithmatic
	
	$bots = get-content $Path | % {
		$p, $v = $_ -split " "
		[PSCustomObject]@{
			p = [int[]](($p).TrimStart("p=") -split ",")
			v = [int[]](($v).TrimStart("v=") -split ",")
		}
	}

	$width = 101
	$height = 103
	$rounds = 100


	foreach ($bot in $bots) {
		$bot.p[0] = ($bot.p[0] + $bot.v[0] * $rounds + $rounds * $width) % $width
		$bot.p[1] = ($bot.p[1] + $bot.v[1] * $rounds + $rounds * $height) % $height
	}

	($bots | ? { $_.p[0] -lt ($width - 1) / 2 -and $_.p[1] -lt ( $height - 1) / 2 }).count *
	($bots | ? { $_.p[0] -lt ($width - 1) / 2 -and $_.p[1] -gt ( $height) / 2 }).count *
	($bots | ? { $_.p[0] -gt ($width) / 2 -and $_.p[1] -lt ( $height - 1) / 2 }).count *
	($bots | ? { $_.p[0] -gt ($width) / 2 -and $_.p[1] -gt ( $height) / 2 }).count
    
}

$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

