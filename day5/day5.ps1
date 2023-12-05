#Get input
#$inputSource = "$PSScriptRoot/example.txt" #Answer should be 35 for part 1
$inputSource = "$PSScriptRoot/input.txt"
$inputText = Get-Content $inputSource

<#
      Part 1
    ----------
    Get Seeds
    Get maps
    Convert to mapping functions in an array
    Walk each seed through array of mapping functions
    Select minimum
#>
$seeds = ($inputText[0] | Select-String '.*: (\d+ *)+').Matches.Groups[1].Captures.Value.Trim()

$maps = @(,@())

$range = 3..($inputText.Count-1)
$inputText[$range] | ForEach-Object{
    if($_ -match 'map:'){
        $maps += ,@()
    }
    elseif($_ -ne ''){
        $destStart, $sourceStart, $mapLen = $_.Trim() -split ' '
        $maps[-1]+= [PSCustomObject]@{
            sourceStart = [long]$sourceStart;
            destStart = [long]$destStart;
            mapLen = [long]$mapLen;
        }
    }
}
$locations = $seeds | ForEach-Object{
    $currVal = [long]$_
    $maps | ForEach-Object{
        foreach ($mapping in $_) {
            if( ($currVal -ge $mapping.sourceStart) -and 
                ($currVal -lt ($mapping.sourceStart + $mapping.mapLen)) )
            {
                $offset = $currVal - $mapping.sourceStart
                #new value
                $currVal = $mapping.destStart + $offset
                break # go to next map
            }
        }
    }
    $currVal
}
$part1 = ($locations | measure -Minimum).Minimum
write-host "Part 1: $part1"
