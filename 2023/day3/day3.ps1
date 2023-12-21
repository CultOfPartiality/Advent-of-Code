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

#Part 2

#Find all numbers as before
#if surroundings have an *, log:
#   GearIndex
#   NumberIndex
#   NumberValue
#join all matches on the index
#multiply and sum
$part2 = 0

#First find all numbers near gears
$gearNumbers = @()
for ($lineIndex = 0; $lineIndex -lt $inputText.Count; $lineIndex++) {
    $line = $inputText[$lineIndex]
    #Get previous and next lines, blank if past the start or the end
    $prevline = ($lineIndex -ne 0) ? $inputText[$lineIndex-1] : '.' * $line.length
    $nextline = ($lineIndex -ne ($inputText.Count-1)) ? $inputText[$lineIndex+1] : '.' * $line.length

    #Get all numbers
    (Select-String -InputObject $line '\d+' -AllMatches).Matches | ForEach-Object{
        if($_ -eq $null) { continue }
        $foundNumber = $_
        #Get all chars surrounding the string. Limit the range to inside the block
        $startIndex = ($foundNumber.Index-1) -ge 0 ? $foundNumber.Index-1 : 0
        $length = ($foundNumber.Index - $startIndex) + 
                  (  ($foundNumber.Index+$foundNumber.Length) -lt $line.Length ? $foundNumber.Length+1 : $foundNumber.Length )
        
        #Previous Line
        $gearMatch = (Select-String -InputObject $prevline.Substring($startIndex,$length) '\*' -AllMatches).Matches
        if($gearMatch.Success){
            $gearMatch | ForEach-Object{
                $gearNumbers += @{
                    GearRow=($lineIndex-1);
                    GearIndex=($startIndex+ $_.Index);
                    NumberRow=$lineIndex;
                    NumberIndex=$foundNumber.Index;
                    NumberValue=$foundNumber.Value;
                    Used=$false;
                }
            }
        }
        #Same Line
        $gearMatch = (Select-String -InputObject $line.Substring($startIndex,$length) '\*' -AllMatches).Matches
        if($gearMatch.Success){
            $gearMatch | ForEach-Object{
                $gearNumbers += @{
                    GearRow=$lineIndex;
                    GearIndex=($startIndex + $_.Index);
                    NumberRow=$lineIndex;
                    NumberIndex=$foundNumber.Index;
                    NumberValue=$foundNumber.Value;
                    Used=$false;
                }
            }
        }
        #Next Line
        $gearMatch = (Select-String -InputObject $nextLine.Substring($startIndex,$length) '\*' -AllMatches).Matches
        if($gearMatch.Success){
            $gearMatch | ForEach-Object{
                $gearNumbers += @{
                    GearRow=($lineIndex+1);
                    GearIndex=($startIndex + $_.Index);
                    NumberRow=$lineIndex;
                    NumberIndex=$foundNumber.Index;
                    NumberValue=$foundNumber.Value;
                    Used=$false;
                }
            }
        }
    }
}


$gearNumbers | ForEach-Object{
    $firstNum = $_
    $otherNums = $gearNumbers.Where({ 
                                      ($_.Used -eq $false) -and
                                      ($_.GearRow -eq $firstNum.GearRow) -and
                                      ($_.GearIndex -eq $firstNum.GearIndex) -and
                                      ($_ -ne $firstNum)
                                    })
    $otherNums | ForEach-Object{
        $part2 += [int]$firstNum.NumberValue * [int]$_.NumberValue
    }
    $firstNum.Used = $true
}



Write-Host "Part 2: $part2"