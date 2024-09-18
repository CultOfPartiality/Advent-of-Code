. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/input.txt"

function Solution {
    param ($Path)

    # Take the input mappings, load the outcomes into an array in order
    # Generate each possible permutation of the input, hash it somehow, and toss in hashmap with the value being the index of the 
    # ouput array

    function Flip-Hoz($pattern) {
        $pattern = foreach ($row in $pattern) {
            $list = [System.Collections.ArrayList]$row
            $list.Reverse()
            , [array]$list
        }
        $pattern
    }

    function Rotate-Clock($pattern) {
        $side = $pattern.Count - 1
        $newPattern = $pattern | % { , $_.clone() }
        for ($i = $side; $i -ge 0; $i--) {
            for ($j = 0; $j -le $side; $j++) {
                $newPattern[$j][$side - $i] = $pattern[$i][$j]
            }
        }
        $newPattern
    }

    function Hash-Pattern($pattern) {
    ($pattern | % { $_ -join "" }) -join ""
    }

    $outcomes = @()
    $inputMapping = @{}
    $data = get-content $Path
    for ($i = 0; $i -lt $data.Count; $i++) {
        $pattern, $outcome = $data[$i] -split " => "
        $outcomes += $outcome
        $pattern = $pattern -split "/" | % { , $_.ToCharArray() }
        # Flip the starting pattern horizontally, then rotate each three times, yeilding the 8 possible arrangements
        $patternAndFlipped = $pattern, (Flip-Hoz($pattern))
        $allPatterns = $patternAndFlipped | % {
            $pattern = $_
            Hash-Pattern($pattern)
            foreach ($rotations in 1..3) {
                $pattern = Rotate-Clock($pattern)
                Hash-Pattern($pattern)
            }
        }
        # Add index to each unique key
        $allpatterns | select -Unique | % {
            $inputMapping[$_] = $i
        }
    }

    $currentPattern = ".#./..#/###" -split "/" | % { , $_.ToCharArray() }

    for ($round = 0; $round -lt 18; $round++) {
        write-host "----------------------`nRound $($round+1)`n----------------------"
        # Prep new array
        $oldGroupSize = ($currentPattern.Count % 2 -eq 0) ? 2 : 3
        $newGroupSize = ($currentPattern.Count % 2 -eq 0) ? 3 : 4
        $newPatternSize = ($currentPattern.Count / $oldGroupSize) * ($oldGroupSize + 1)
        $newPattern = New-Object "object[]" $newPatternSize
        foreach ($rowNum in 0..($newPatternSize - 1)) {
            $newPattern[$rowNum] = New-Object "char[]" $newPatternSize
        }

        # Loop over subgroups of currentPattern, perform the lookup, then allocate to newPattern's subgroup
        for ($subRow = 0; $subRow -lt ($currentPattern.Count / $oldGroupSize) ; $subRow++) {
            for ($subCol = 0; $subCol -lt ($currentPattern.Count / $oldGroupSize); $subCol++) {
                #write-host "Row $subRow, col $subCol"
                # Generate sub array
                $rowRange = ($subRow * $oldGroupSize)..($subRow * $oldGroupSize + $oldGroupSize - 1)
                $colRange = ($subCol * $oldGroupSize)..($subCol * $oldGroupSize + $oldGroupSize - 1)
                $subArray = $currentPattern[$rowRange] | % { , $_[$colRange] }
                #$subArray | % { write-host ($_ -join "") }
                # Do the hash and lookup
                $enhanceIndex = $inputMapping[ (Hash-Pattern($subArray))]
                $enhancement = $outcomes[$enhanceIndex] -split "/"
                # Insert into newPattern
                $newRowIndex = $subRow * $newGroupSize
                $newColIndex = $subCol * $newGroupSize
                for ($r = $newRowIndex; $r -lt $newRowIndex + $newGroupSize; $r++) {
                    for ($i = 0; $i -lt $newGroupSize; $i++) {
                        $newPattern[$r][$newColIndex + $i] = $enhancement[$r % $newGroupSize][$i]
                    }
                }
            }
        }
        $currentPattern = $newPattern
        #Write-Host "`n Enhanced:"
        #$currentPattern | % { write-host ($_ -join "") }
        #write-host ""
        if ($Path -match "test1.txt" -and $round -eq 1) { break }
    }

    $onPixels = $currentPattern | % { $_ | ? { $_ -eq "#" } }
    $onPixels.Count
}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 12
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

