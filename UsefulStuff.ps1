# A collection of useful funcitons that keep croping up, or were complex to workout and might be useful in part


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

#Given an array of unique options, returns an array of each possible pairing
function Get-AllPairs {
	param ($array)

	$a = @() + $array
	$b = @() + $array

	if($array.count -eq 2){
		return ,$array
	}

	
	$b = $b | % {
		$current = $_
		$a = $a | ? { $current -ne $_ }
		$a | % {
			, @($current, $_)
		}
	}
	$b
}

#given an array, provide all possible orderings
function Get-AllPermutations {
	param ($array)

	$a = $array

	$b = $a | % { , @($_) }

	while ($b[0].Count -lt $a.Count) {
		$b = $b | % {
			$current = $_
			$valuesLeft = $a | ? { $current -notcontains $_ }
			$valuesLeft | % {
				, @($current + $_)
			}
		}
	}
	$b
}

# Find the greatest common demominator between two values
function gcd { 
	param ($a, $b)
	#Euclidean Algorithm
	while ($b -ne 0) {
		$temp = $b
		$b = $a % $b
		$a = $temp 
	}
	$a
}

# Lowest Common Multiple, either between 2 values or an array of values
function lcm {
	param($a, $b)
	$a * ($b / (gcd $a $b))
}
function lcm_array {
	param($array)
	$lcm = 1
	foreach ($el in $array) {
		$lcm = lcm $lcm $el
	}
	$lcm
}

# MD5 hashing
#  This keeps cropping up
#  This version is a bit faster, and already provides a lowercase version which seems more useful
$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$utf8 = New-Object -TypeName System.Text.UTF8Encoding
function MD5 {
	param ([string]$in)
    ([System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($in))).ToLower().Replace("-", ""))
}

# A classic - finding primes
#  It's in shorthand, so use parethesis for args!
function isPrime($num) {
	$num = [System.Math]::abs($num)
	if ($num -eq 1) { return $false }
	if ($num -eq 2) { return $true }
	$prime = $true
	2..([int][Math]::Sqrt($num)) | % {
		if ( ($num % $_) -eq 0) {
			$prime = $false
			return
		}
	}
	return $prime
}

# Split an array up into groups of x, or y groups
# Will attempt to make that many, but might not if the size doesn't work out
# Accepts pipeline input
function Split-Array {

	[CmdletBinding()]
	param(
		[Parameter(Mandatory, ValueFromPipeline)] $Array,
		$GroupSize,
		$Groups = -1
	)

	# Get the array from the pipeline, as an actual array and not unrolled
	if( $input ){
	 	$Array = $input
	}

	# Recalcuate group size if number of groups required
	if ($Groups -gt 0) {
		$GroupSize = [Math]::Ceiling($Array.Count / $Groups)
	}

	# Actual amount of groups created
	$Groups = [Math]::Ceiling($Array.Count / $GroupSize)

	# If only returning one group, we still need to force it to return an array of arrays
	if($Groups -eq 1){
		return ,($Array)
	}
	
	$index = 0
	while ($index -lt $Array.Count) {
		,$Array[$index..($index + $GroupSize - 1)]
		$index += $GroupSize
	}
	return
}


function Sum-Array {

	[CmdletBinding()]
	param(
		[Parameter(Mandatory, ValueFromPipeline)] $Array
	)

	# Get the array from the pipeline, as an actual array and not unrolled
	if( $input ){
		$Array = $input
   	}

	($Array | Measure-Object -Sum).Sum
}

function Multiply-Array {

	[CmdletBinding()]
	param(
		[Parameter(Mandatory, ValueFromPipeline)] $Array
	)

	# Get the array from the pipeline, as an actual array and not unrolled
	if( $input ){
		$Array = $input
   	}

	if($Array.Count -eq 1){
		$Array[0]
	}
	else{
		[int64]$acc = $Array[0]
		for ($i = 1; $i -lt $Array.Count; $i++) {
			$acc *= $Array[$i]
		}
		$acc
	}
}

# Calculate the manhattan distance for the received array 
function Manhattan-Distance {

	[CmdletBinding()]
	param(
		[Parameter(Mandatory, ValueFromPipeline)] $Array
	)

	# Get the array from the pipeline, as an actual array and not unrolled
	if( $input ){
		$Array = $input
   	}

	($Array | %{[Math]::Abs($_)} | Measure-Object -Sum).Sum
}