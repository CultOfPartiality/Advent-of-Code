#works to 40, but not really fast enough for 50

$inputText = [char[]]"1113222113"

function LookAndSay {
	param ($inputString)
	
	$curChar = $inputText[0]
	$count = 1
	$newString = ''
	foreach($char in $inputText[1..($inputText.Length-1)]){
		if($char -eq $curChar){$count++}
		else{
			$newString+="$count$curChar"
			$curChar = $char
			$count = 1
		}
	}
	$newString+"$count$curChar"
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