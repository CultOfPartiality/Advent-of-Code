. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $rawRules, $rawMyTicket, $rawTickets = (get-content $Path -Raw) -split ([System.Environment]::NewLine * 2)

    $rules = $rawRules -split [System.Environment]::NewLine | % {
        , ($_ -replace ".*: ", "" -split " or " | % { , @([int[]]($_ -split "-")) })
    }

    $rawTickets -split [System.Environment]::NewLine | select -skip 1 | % {
        $invalidFields = @()
        [int[]]$values = $_ -split ","
        foreach ($value in $values) {
            $valueValid = $false
            :ruleChecks
            foreach ($rule in $rules) {
                foreach ($range in $rule) {
                    if ($range[0] -le $value -and $value -le $range[1]) {
                        $valueValid = $true
                        break ruleChecks
                    }
                }
            }
            if (! $valueValid) {
                $invalidFields += $value
            }
        }
        $invalidFields
    } | Sum-Array

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 71
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

