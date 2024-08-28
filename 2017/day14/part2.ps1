. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

# Knot-Hashing function from day 10
. "$PSScriptRoot\..\day10\knot_hash.ps1"

#The following line is for development
$in = "flqrgnkx"

function Solution {
	param ($in)

	$hashes = 0..127 | % { Knot-Hash ($in + "-" + $_) }
	$binaryData = $hashes | % {
		$_.ToCharArray() | % {
			$int = [System.Convert]::ToInt32($_, 16)
			[system.convert]::ToString($int, 2).PadLeft(4, "0")
		} | Join-String
	}
	
	#Now do blob detection...
	#todo
	#todo
}

Unit-Test  ${function:Solution} "flqrgnkx" 8108
$measuredTime = measure-command { $result = Solution "hfdlxzhv" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

