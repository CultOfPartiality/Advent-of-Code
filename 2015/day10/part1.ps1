$inputText = "1113222113"
#$newString = [char[]]::new(5000000)

function LookAndSay {
	param ($inputString)
	
	$curChar = $inputString[0]
	$count = 0
	$newString = [char[]]::new($inputString.Length*2)
	$newCharIndex = 0
	for ($i = 0; $i -lt $inputString.Length; $i++) {
		if($inputString[$i] -eq $curChar){$count++}
		else{
			$newString[$newCharIndex++]="$count"
			$newString[$newCharIndex++]=$curChar
			$curChar = $inputString[$i]
			$count = 1
		}
	}
	$newString[$newCharIndex++]="$count"
	$newString[$newCharIndex]=$curChar
	$newString[0..$newCharIndex]
}

foreach($i in 1..40){
	$inputText = LookAndSay $inputText
	Write-Host "Cycle $i finished"
}
"Result 1: $($inputText.Length) chars"

foreach($i in 41..50){
	$inputText = LookAndSay $inputText
	Write-Host "Cycle $i finished"
}
"Result 2: $($inputText.Length) chars"