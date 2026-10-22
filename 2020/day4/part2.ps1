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
        $validity = $true

        $byr = [int][regex]::Match($passport, "byr:(\d{4})").Groups[1].Value
        # write-host "byr: $byr"
        $validity = $validity -and ($byr -ge 1920 -and $byr -le 2002)
        
        $iyr = [int][regex]::Match($passport, "iyr:(\d{4})").Groups[1].Value
        # write-host "iyr: $iyr"
        $validity = $validity -and ($iyr -ge 2010 -and $iyr -le 2020)
        
        $eyr = [int][regex]::Match($passport, "eyr:(\d{4})").Groups[1].Value
        # write-host "eyr: $eyr"
        $validity = $validity -and ($eyr -ge 2020 -and $eyr -le 2030)

        $hgt = [int][regex]::Match($passport, "hgt:(\d*)(in|cm)").Groups[1].Value
        $unit = [regex]::Match($passport, "hgt:(\d*)(in|cm)").Groups[2].Value
        $validity = $validity -and ($unit -eq "in" ? ($hgt -ge 59 -and $hgt -le 76) : ($hgt -ge 150 -and $hgt -le 193) )
    
        $validity = $validity -and [regex]::Match($passport, "hcl:#[0-9a-f]{6}(?![0-9a-f])").Success

        $validity = $validity -and [regex]::Match($passport, "ecl:(amb|blu|brn|gry|grn|hzl|oth)").Success

        $validity = $validity -and [regex]::Match($passport, "pid:\d{9}(?!\d)").Success

        $validity
    }
    $valid.count
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 2
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 0
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" 4
Unit-Test  ${function:Solution} "$PSScriptRoot/input.txt" 175
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

