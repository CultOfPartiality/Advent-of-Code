. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
    param ($Path)

    #The following line is for development
    # $Path = "$PSScriptRoot/testcases/test1.txt"

    $data = (get-content $Path).Split(", ") | % { [PSCustomObject]@{
            Turn     = $_[0]
            Distance = [int]$_.Substring(1)
        } }

    #North = 0, East = 1, etc.
    $state = [PSCustomObject]@{
        Direction = 0
        Lat       = 0
        Long      = 0
    }


    $data | % {
        $instruction = $_
        $state.Direction = ($state.Direction + ($_.Turn -eq "R" ? 1 : -1)) % 4
        $state.Direction = ($state.Direction -eq -1) ? 3 : $state.Direction
        switch ($state.Direction) {
            0 { $state.Lat += $instruction.Distance }
            1 { $state.Long += $instruction.Distance }
            2 { $state.Lat -= $instruction.Distance }
            3 { $state.Long -= $instruction.Distance }
        }
    }

    [Math]::Abs($state.Lat) + [Math]::Abs($state.Long)

}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 5
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 2
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" 12
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 1: $result" -ForegroundColor Magenta

