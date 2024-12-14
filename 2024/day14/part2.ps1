. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

$Path = "$PSScriptRoot/input.txt"

$bots = get-content $Path | % {
	$p, $v = $_ -split " "
	[PSCustomObject]@{
		p = [int[]](($p).TrimStart("p=") -split ",")
		v = [int[]](($v).TrimStart("v=") -split ",")
	}
}

$width = 101
$height = 103

function print-bots{
	$map = new-object "char[,]" $height,$width
	foreach ($bot in $bots) {
		$map[$bot.p[1],$bot.p[0]] = "x"
	}
	for ($y = 0; $y -lt $height; $y++) {
		$row = ""
		for ($x = 0; $x -lt $width; $x++) {
			$row += $map[$y,$x] -eq 0 ? " " : "x"
		}
		write-host $row
	}
}


# After some inspection, a 'wide' pattern appears and begins reappearing ever 103 cycles after round 207
# A 'skinny' pattern appears and begins reapperaing every 101 cycles after round 248.

# Xmax Tree Rounds = 207 + a*103 = 248 + b*101
# a = (41 + b*101)/103

$b=0
do{
	$b++
	$a = (41 + $b*101)/103
}
while($a % 1 -ne 0)

$rounds = 207 + $a*103
foreach($bot in $bots){
	$bot.p[0] = ($bot.p[0] + $bot.v[0]*$rounds + $rounds*$width) % $width
	$bot.p[1] = ($bot.p[1] + $bot.v[1]*$rounds + $rounds*$height) % $height
}
print-bots

Write-Host "Part 2: $rounds" -ForegroundColor Magenta

