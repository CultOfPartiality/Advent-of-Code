$inputSource = "$PSScriptRoot/input.txt"

#Setup array of lights
$lights = New-Object 'object[,]' 1000, 1000
foreach($i in 0..999){
	foreach($j in 0..999){
		$lights[$i,$j] = $false
	}
}

get-Content $inputSource | ForEach-Object{
	switch ( [regex]::Match($_,'\D* ?\D*') ) {
		'turn on' {  }
		'turn off' {  }
		'toggle' {  }
		Default {}
	}	
}