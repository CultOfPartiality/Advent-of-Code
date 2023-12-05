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

Clear-Variable maps
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





# $rawMaps = $inputText | Select-String '(.*) map:[\n\r]+((\d+ ?)*[\n\r]+)+' -AllMatches | Select -ExpandProperty Matches | ForEach-Object { [PSCustomObject]@{Name = $_.Groups[1].Value; Map = $_.Groups[2].Captures } }    
# $maps = $rawMaps | ForEach-Object {
#     $tempMapping = @{}
#     $_.Map | ForEach-Object {
#         $destStart, $sourceStart, $mapLen = $_.Value.Trim() -split ' '
#         for ($j = 0; $j -lt $mapLen; $j++) {
#             $tempMapping.Add([string]([long]$sourceStart + $j), [string]([long]$destStart + $j))
#         }
#     }
#     $tempMapping
# }

# $locations = $seeds | ForEach-Object{
#     $currVal = $_
#     $maps | ForEach-Object{
#         $map = $_
#         $currVal = $map.ContainsKey("$currVal") ? $map["$currVal"] : $currVal
#     }
#     $currVal
# }
# $part1 = ($locations | measure -Minimum).Minimum
# write-host "Part 1: $part1"