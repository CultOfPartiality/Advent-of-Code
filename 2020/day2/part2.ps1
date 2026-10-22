. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $entries = get-content $Path | % { , @($_ -split " ") } | % {
        [pscustomobject]@{
            positions = [int[]] ($_[0] -split "-")
            letter   = [char] $_[1].TrimEnd(":")
            password = $_[2]
        }
    }

    $valid = $entries | ? {
        $_.password[$_.positions[0]-1] -eq $_.letter -xor 
        $_.password[$_.positions[1]-1] -eq $_.letter
    }

    $valid.count

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 1
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
# 683 too low

