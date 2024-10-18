
#Transpose an array of strings
function Transpose-ArrayOfStrings {
	param([string[]]$array)
	0..($block[0].Length - 1) | % {
		$col = $_
		0..($array.Count - 1) | % {
			$row = $_
			$array[$row][$col]
		} | Join-String
	}
}

#Given an array of unique options, returns array each possible pairing
function Get-AllPairs {
	param ($array)

	$a = @()+$array
	$b = @()+$array

	#while ($b.Count -lt $a.Count) {
		$b = $b | % {
			$current = $_
			$a = $a | ? { $current -ne $_ }
			$a | % {
				, @($current,$_)
			}
		}
	#}
	$b
}

#given an array, provide all possible orderings
function Get-AllPermutations {
	param ($array)

	$a = $array

	$b = $a|%{,@($_)}

	while($b[0].Count -lt $a.Count){
		$b = $b|%{
			$current = $_
			$valuesLeft = $a|?{$current -notcontains $_}
			$valuesLeft | %{
				,@($current+$_)
			}
		}
	}
	$b
}

function gcd{ 
    param ($a,$b)
    #Euclidean Algorithm
    while($b -ne 0){
        $temp = $b
        $b = $a % $b
        $a = $temp 
    }
    $a
}

function lcm{
    param($a,$b)
    $a * ($b/(gcd $a $b))
}
function lcm_array{
    param($array)
	$lcm = 1
	foreach($el in $array){
    	$lcm = lcm $lcm $el
	}
	$lcm
}

#This keeps cropping up
#This version is a bit faster, and already provides a lowercase version which seems more usefull
$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$utf8 = New-Object -TypeName System.Text.UTF8Encoding
function MD5 {
    param ([string]$in)
    ([System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($in))).ToLower().Replace("-",""))
}

#Shorthand, use parethesis!
#Works for +ve numbers
function isPrime($num){
	$num = [System.Math]::abs($num)
	if($num -eq 1){ return $false}
	if($num -eq 2){ return $true}
	$prime = $true
	2..([int][Math]::Sqrt($num)) | %{
		if( ($num % $_) -eq 0){
			$prime = $false
			return
		}
	}
	return $prime
}