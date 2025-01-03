$inputSource = "$PSScriptRoot/input.txt"

#Setup array of lights
$lights = New-Object 'object[,]' 1000, 1000
foreach($i in 0..999){
	foreach($j in 0..999){
		$lights[$i,$j] = $false
	}
}

get-Content $inputSource | ForEach-Object{
	$x0,$y0,$x1,$y1 = ($_ | Select-String '\d+' -AllMatches).Matches.Value | %{[int]$_}
	$action = [Regex]::Match($_,'toggle|on|off')
	for ($x = $x0; $x -le $x1; $x++) {
		for ($y = $y0; $y -le $y1; $y++) {
			switch ($action) {
				'toggle' {$lights[$x,$y] = -not $lights[$x,$y]}
				'off' 	 {$lights[$x,$y] = $false}
				'on'     {$lights[$x,$y] = $true}
			}
		}
	}
}
Write-Host "$(($lights|group|where {$_.name -eq "True"}).Count) lights are on"