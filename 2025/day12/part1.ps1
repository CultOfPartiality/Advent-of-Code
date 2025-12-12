. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/input.txt"

function Solution {
	param ($Path)

	#TODO Once complete, move this into standard library
	function split-array {
		[CmdletBinding()]
		param(
			[Parameter(Mandatory, ValueFromPipeline)] $Array,
			[Parameter()] $Delimiter
		)
		# Get the array from the pipeline, as an actual array and not unrolled
		if ( $input ) { $Array = $input }

		$temp = @()
		$result = @()
		foreach ($element in $Array) {
			if ($element -eq $Delimiter) {
				$result += , $temp
				$temp = @()
			}
			else {
				$temp += $element
			}
		}
		if ($temp.count -gt 0) {
			$result += , $temp
		}
	
		return $result
	}

	$data = get-content $Path | split-array -Delimiter ""

	$pieces = $data[0..($data.count - 2)] | % {
		$size = ($_[1..3] | % { $_.ToCharArray() } | ? { $_ -eq "#" }).Count
		[pscustomobject]@{
			size = $size
		}
	}
	$regions = $data[-1] | % {
		$split = $_ -replace ":", "" -split " "
	
		[PSCustomObject]@{
			dimensions  = (  $split[0] -split "x" | % { [int]$_ }  )
			numOfPieces = (  $split | select -Skip 1 | % { [int]$_ }  )
			area        = (  $split[0] -split "x" | % { [int]$_ } | Multiply-Array )
		}
	}

	$regionCount = 0
	$validRegions = 0
	$invalidRegions = 0
	foreach ($region in $regions) {
		write-host "Region $regionCount"
		$regionCount++
	
		$minRequiredArea = 0..($pieces.Count - 1) | % { $region.numOfPieces[$_] * $pieces[$_].size } | sum-array
		write-host "`tRequire area: $minRequiredArea, actual area: $($region.area)"
		if ($minRequiredArea -gt $region.area) {
			write-host "`t Can't be done, require area is larger than actual area" -ForegroundColor DarkRed
			$invalidRegions++
			continue
		}

		$totalPiecesRequired = $region.numOfPieces | sum-array
		$worstCaseArea = $totalPiecesRequired * 3 * 3
		$areaOfRegionAllowingOnly3x3s = $region.dimensions | % { [Math]::Floor($_ / 3) * 3 } | Multiply-Array
		write-host "`tTotal pieces required: $totalPiecesRequired, worst case max area: $worstCaseArea, region area if only allowing 3x3s: $areaOfRegionAllowingOnly3x3s"
		if ($worstCaseArea -le $areaOfRegionAllowingOnly3x3s) {
			write-host "`tWorst case area (each piece gets a full 3x3) works" -ForegroundColor DarkGreen
			$validRegions++
			continue
		}
		write-host "`tStill unsure" -ForegroundColor DarkYellow
	}
	write-host "Valid regions: " -NoNewline; write-host $validRegions -ForegroundColor Green -NoNewline
	write-host ", unsure regions: " -NoNewline; write-host ($regions.Count - $validRegions - $invalidRegions) -ForegroundColor Yellow -NoNewline
	write-host ", invalid regions: " -NoNewline; write-host $invalidRegions -ForegroundColor Red

	$validRegions


}
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

