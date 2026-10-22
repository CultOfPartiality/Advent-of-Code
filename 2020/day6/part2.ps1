. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)
    
    $groupsRaw = (get-content $Path -Raw) -split ([Environment]::NewLine*2)
    $groups = $groupsRaw | %{,($_ -split [Environment]::NewLine)}

    $groups | %{
        $NumOfPeople = $_.Count
        $commonYes = ($_ -join "").ToCharArray() | group | ?{
            $_.Count -eq $NumOfPeople
        } | %{$_.Name}
        $commonYes.Count
    } | Sum-Array
   
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 6
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

