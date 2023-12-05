#Get input
#$inputSource = "$PSScriptRoot/example.txt" #Answer should be 46 for part 2
$inputSource = "$PSScriptRoot/input.txt"
$inputText = Get-Content $inputSource

#Get seed ranges
$seeds = ($inputText[0] | Select-String '.*: (\d+ \d+ ?)+').Matches.Groups[1].Captures.Value | % {
	$start, $length = $_.trim() -split ' '
	[PSCustomObject]@{
		start = [long]$start;
		end   = [long]$start + [long]$length - 1;
		len   = [long]$length;
	}
}

#Get mappings
$maps = @(, @())
$range = 3..($inputText.Count - 1)
$inputText[$range] | ForEach-Object {
	if ($_ -match 'map:') {
		$maps += , @()
	}
	elseif ($_ -ne '') {
		$destStart, $sourceStart, $mapLen = $_.Trim() -split ' '
		$maps[-1] += [PSCustomObject]@{
			sourceStart = [long]$sourceStart;
			sourceEnd   = [long]$sourceStart + [long]$mapLen - 1;
			destStart   = [long]$destStart;
			destEnd     = [long]$destStart + [long]$mapLen - 1;
			mapLen      = [long]$mapLen;
		}
	}
}

#Do the mappings
#If crosses range, add range for seeds that don't get mapped to end
#in this version, do all seeds for each map in turn
$maps | ForEach-Object {
	$map = $_
	for ($i = 0; $i -lt $seeds.Count; $i++) {
		for ($j = 0; $j -lt $map.Count; $j++) {
			$mapping = $map[$j]
			$seedRange = [PSCustomObject]@{
				start = $seeds[$i].start;
				end = $seeds[$i].end;
				len = $seeds[$i].len;
			}
			#possible outcomes
			#	seed entirely inside mapping
			#	seed starts insite mapping and extends out of it
			#	seed starts outside mappinng and extends into it
			$startInside = ($seedRange.start -ge $mapping.sourceStart -and $seedRange.start -le $mapping.sourceEnd)
			$endInside = ($seedRange.end -ge $mapping.sourceStart -and $seedRange.end -le $mapping.sourceEnd)
			if ($startInside -and $endInside) {
				#The whole seed range is remapped
				$offset = $seedRange.start - $mapping.sourceStart
				$seeds[$i].start = $mapping.destStart + $offset
				$seeds[$i].end = $seeds[$i].start + $seeds[$i].len - 1
				break #don't process any more mappings for this seed
			}
			elseif ($startInside -and -not $endInside) {
				#The start is remapped, and the end appended as a new seed range
				$offset = $seedRange.start - $mapping.sourceStart
				$seeds[$i].start = $mapping.destStart + $offset
				$seeds[$i].end = $mapping.destEnd
				$seeds[$i].len = $seeds[$i].end - $seeds[$i].start + 1;
			
				$seeds += [PSCustomObject]@{
					start = $seedRange.start + $seeds[$i].len;
					end   = $seedRange.end;
					len   = $seedRange.end - ($seedRange.start + $seeds[$i].len) + 1;
				}
				break #don't process any more mappings for this seed
			}
			elseif (-not $startInside -and $endInside) {
				#The end is remapped, and the start appended as a new seed range
				$offset = $seedRange.end - $mapping.sourceStart
				$seeds[$i].start = $mapping.destStart
				$seeds[$i].end = $mapping.destStart + $offset
				$seeds[$i].len = $seeds[$i].end - $seeds[$i].start + 1;
			
				$seeds += [PSCustomObject]@{
					start = $seedRange.start;
					end   = $mapping.sourceStart - 1;
					len   = ($mapping.sourceStart - 1) - $seedRange.start + 1;
				}
				break #don't process any more mappings for this seed
			}
		}
	}
}
$part2 = ($seeds.start | measure -Minimum).Minimum
write-host "Part 1: $part2"