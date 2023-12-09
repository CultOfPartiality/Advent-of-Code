$inputSource = "$PSScriptRoot/input.txt"

#Setup array of lights
$lights = New-Object 'object[,]' 1000, 1000
foreach($i in 0..999){
	foreach($j in 0..999){
		$lights[$i,$j] = 0
	}
}

$count = 1
get-Content $inputSource | ForEach-Object{
    write-host "Instruction $count/300"
    $count++
	$x0,$y0,$x1,$y1 = ($_ | Select-String '\d+' -AllMatches).Matches.Value | %{[int]$_}
	$action = [Regex]::Match($_,'toggle|on|off')
	for ($x = $x0; $x -le $x1; $x++) {
		for ($y = $y0; $y -le $y1; $y++) {
			switch ($action) {
				'toggle' {$lights[$x,$y] += 2}
				'off' 	 {$lights[$x,$y] = $lights[$x,$y] -eq 0 ? 0 : $lights[$x,$y]-1 }
				'on'     {$lights[$x,$y] += 1}
			}
		}
	}
}
Write-Host "$(($lights|measure -sum).Sum) total brightness"