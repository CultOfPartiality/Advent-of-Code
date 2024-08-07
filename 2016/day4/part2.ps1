. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

# function Solution {
# 	param ($Path)


	$data = get-content $Path | % {
		$matches = (Select-String -InputObject $_ -pattern "([\w-]+)-(\d+)\[(.+)\]").Matches.Groups
		[PSCustomObject]@{
			code	 = $Matches[1].Value
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
    
	$validData | %{
		$shiftCount = $_.sector
		$_.code.ToCharArray() | %{
			
		}
	}


# }

# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 1514
# $result = Solution "$PSScriptRoot\input.txt"
# Write-Host "Part 2: $result" -ForegroundColor Magenta

