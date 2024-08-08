. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/input.txt"

# function Solution {
# 	param ($Path)


$data = get-content $Path | % {
	$matches = (Select-String -InputObject $_ -pattern "([\w-]+)-(\d+)\[(.+)\]").Matches.Groups
	[PSCustomObject]@{
		code     = $Matches[1].Value
		shiftedCode = ""
		sector   = $Matches[2].Value
		checksum = $Matches[3].Value
	}
}

$validData = $data | % {
	$groupedCode = ($_.code -replace "-", "").ToCharArray() | group-object | Sort-Object -Property @{Expression = "Count"; Descending = $true }, @{Expression = "Name"; Descending = $false }
	$predictedChecksum = $groupedCode[0..4].name -join ""
	if ($predictedChecksum -eq $_.checksum) {
		$_
	}
}
    
$validData | % {
	$shiftCount = $_.sector
	$shiftedCode = $_.code.ToCharArray() | % {
		$value = [byte][char]$_
		if ($_ -eq "-") {
			$value = " "
		}
		else {
			for ($i = 0; $i -lt $shiftCount; $i++) {
				$value = $value -eq 122 ? 97 : $value + 1
			}
		}
		[char]$value
	}
	$_.shiftedCode = $shiftedCode -join ""
}

$validData |? {$_.shiftedCode | select-string "North"}

# }

# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 1514
# $result = Solution "$PSScriptRoot\input.txt"
# Write-Host "Part 2: $result" -ForegroundColor Magenta

