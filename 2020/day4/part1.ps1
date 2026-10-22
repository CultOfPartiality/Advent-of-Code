. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $rawPassports = (get-content $Path -Raw) -split ([System.Environment]::NewLine + [System.Environment]::NewLine)
    $fields = "byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"#,"cid"

    $valid = $rawPassports | ? {
        $passport = $_
        foreach ($field in $fields) {
            if ($passport -notmatch "$($field):.*") {
                return $false
            }
        }
        return $true
    }
    $valid.count
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 2
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

