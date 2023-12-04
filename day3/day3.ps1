$exampleText = Get-Content "$PSScriptRoot/example.txt"
$sum = 0
for ($lineIndex = 0; $lineIndex -lt $exampleText.Count; $lineIndex++) {
    $line = $exampleText[$lineIndex]
    #Get previous and next lines, blank if past the start or the end
    $prevline = ($lineIndex -ne 0) ? $exampleText[$lineIndex-1] : '.' * $line.length
    $nextline = ($lineIndex -ne ($exampleText.Count-1)) ? $exampleText[$lineIndex+1] : '.' * $line.length

    #Get all numbers
    (Select-String -InputObject $line '\d+' -AllMatches).Matches | ForEach-Object{
        if($_ -eq $null) { continue }
        #Get all characters surrounding the string. Limit the range to inside the block
        $startIndex = ($_.Index-1) -ge 0 ? $_.Index-1 : 0
        $length = ($_.Index - $startIndex) + 
                  (  ($_.Index+$_.Length) -lt $line.Length ? $_.Length+1 : $_.Length )
        $surroundingChars = $prevline.Substring($startIndex,$length) + "`n" + 
                            $line.Substring($startIndex,$length) + "`n" +
                            $nextline.Substring($startIndex,$length)
        #Write-Host "Found section:`n$surroundingChars"
        #Search for not period or number chars. If successful add number to sum
        if( (Select-String -InputObject $surroundingChars '[^\d\s\.]').Matches.Success ){
            #Write-Host "Valid!"
            $sum += $_.Value
        }
    }
}
Write-Host "Example Sum $sum, expected answer: 4361"

$inputText = Get-Content "$PSScriptRoot/input.txt"
$sum = 0
for ($lineIndex = 0; $lineIndex -lt $inputText.Count; $lineIndex++) {
    $line = $inputText[$lineIndex]
    #Get previous and next lines, blank if past the start or the end
    $prevline = ($lineIndex -ne 0) ? $inputText[$lineIndex-1] : '.' * $line.length
    $nextline = ($lineIndex -ne ($inputText.Count-1)) ? $inputText[$lineIndex+1] : '.' * $line.length

    #Get all numbers
    (Select-String -InputObject $line '\d+' -AllMatches).Matches | ForEach-Object{
        if($_ -eq $null) { continue }
        #Get all characters surrounding the string. Limit the range to inside the block
        $startIndex = ($_.Index-1) -ge 0 ? $_.Index-1 : 0
        $length = ($_.Index - $startIndex) + 
                  (  ($_.Index+$_.Length) -lt $line.Length ? $_.Length+1 : $_.Length )
        $surroundingChars = $prevline.Substring($startIndex,$length) + "`n" + 
                            $line.Substring($startIndex,$length) + "`n" +
                            $nextline.Substring($startIndex,$length)
        #Write-Host "Found section:`n$surroundingChars"
        #Search for not period or number chars. If successful add number to sum
        if( (Select-String -InputObject $surroundingChars '[^\d\s\.]').Matches.Success ){
            #Write-Host "Valid!"
            $sum += $_.Value
        }
    }
}
Write-Host "Part 1 sum: $sum"

