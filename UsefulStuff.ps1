
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

#This keeps cropping up
#This version is a bit faster, and already provides a lowercase version which seems more usefull
function MD5 {
    param ([string]$in)
    ([System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($in))).ToLower().Replace("-",""))
}