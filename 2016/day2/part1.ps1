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
                "U" { ($CurrentButton -gt 3) ? $CurrentButton - 3 : $CurrentButton }
                "D" { ($CurrentButton -lt 7) ? $CurrentButton + 3 : $CurrentButton }
                "L" { ((($CurrentButton - 1) % 3) -gt 0) ? $CurrentButton - 1 : $CurrentButton }
                "R" { ((($CurrentButton - 1) % 3) -lt 2) ? $CurrentButton + 1 : $CurrentButton }
            }
        }
        $CurrentButton
    }

    $code | % { "$_" } | Join-String

}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 1985
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 1: $result" -ForegroundColor Magenta

