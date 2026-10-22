. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $entries = get-content $Path | % { , @($_ -split " ") } | % {
        $min, $max = [int[]] ($_[0] -split "-")
        [pscustomobject]@{
            min      = $min
            max      = $max
            letter   = [char] $_[1].TrimEnd(":")
            password = $_[2]
        }
    }

    $valid = $entries | ? {
        $groupedLetters = $_.password.ToCharArray() | Group-Object -AsHashTable
        $count = $groupedLetters[$_.letter].Count
        $count -ge $_.min -and $count -le $_.max
    }

    $valid.count

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 2
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

