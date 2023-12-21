. "$PSScriptRoot\..\Unit-Test.ps1"

function HASH {
    param ([String]$inputStr)
    $currentValue = 0
    [char[]]$inputStr | % {
        $ascii = [int][byte][char]$_
        $currentValue = ($currentValue + $ascii) * 17 % 256
    }
    return $currentValue
}

function Initialize-Seq {
    param ($Path)
    $data = Get-Content $Path
    $data = $data -split ","

    #Setup the lense array of ordered hashes
    $boxes = 0..255 | %{[ordered]@{}}

    $data | % {
        $op = [Regex]::Match($_,'[=-]').Value
        $label = [Regex]::Match($_,'[a-z]*').Value
        $boxNum = HASH $label
        if($op -eq "-"){
            #Remove any lenses from the box with that label
            $boxes[$boxNum].Remove($label)
        }
        else{ # $op -eq "="
            $focalLength = [int][string]$_[-1]
            if($boxes[$boxNum][$label]){
                $boxes[$boxNum][$label] = $focalLength
            }
            else{
                $boxes[$boxNum][$label] = $focalLength
            }
        }
    }

    $sum = 0
    for ($box = 0; $box -lt $boxes.Count; $box++) {
        if($boxes[$box].Count -eq 0){continue}

        for ($slot = 0; $slot -lt $boxes[$box].Count; $slot++) {
            $sum += ($box+1) * ($slot+1) * $boxes[$box][$slot]
        }
    }

    return $sum
}

Unit-Test  ${function:Initialize-Seq} "$PSScriptRoot\testcases\test1.txt" 145
$result = Initialize-Seq "$PSScriptRoot\input.txt"
Write-Host "Part 2: $result" -ForegroundColor Magenta