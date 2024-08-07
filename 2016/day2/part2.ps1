. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
    param ($Path)

    #The following line is for development
    # $Path = "$PSScriptRoot/testcases/test1.txt"

    $data = get-content $Path | % { , @($_.ToCharArray()) }

    $CurrentButton = 5
    $code = foreach ($line in $data) {
        foreach ($inst in $line) {
            $CurrentButton = switch ($inst) {
                "U" {
                    switch ($CurrentButton) {
                        {$_ -in (6,7,8,10,11,12)} { $CurrentButton-4 }
                        {$_ -in (3,13)} { $CurrentButton-2 }
                        default {$CurrentButton}
                    }
                }
                "D" {
                    switch ($CurrentButton) {
                        {$_ -in (2,3,4,6,7,8)} { $CurrentButton+4 }
                        {$_ -in (1,11)} { $CurrentButton+2 }
                        default {$CurrentButton}
                    }
                }
                "L" {
                    switch ($CurrentButton) {
                        {$_ -in (3,4,6,7,8,9,11,12)} { $CurrentButton-1 }
                        default {$CurrentButton}
                    }
                }
                "R" {
                    switch ($CurrentButton) {
                        {$_ -in (2,3,5,6,7,8,10,11)} { $CurrentButton+1 }
                        default {$CurrentButton}
                    }
                }
            }
        }
        [System.String]::Format("{0:X}",$CurrentButton)
    }

    $code | % { "$_" } | Join-String

}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" "5DB3"
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 1: $result" -ForegroundColor Magenta

