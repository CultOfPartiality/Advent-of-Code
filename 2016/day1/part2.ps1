. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
    param ($Path)

    #The following line is for development
    # $Path = "$PSScriptRoot/testcases/part2_test1.txt"

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
    $locationsVisisted = @{}
    $locationsVisisted.Add("$($state.Lat).$($state.Long)", 1)


    $done = $false
    for ($instIndex = 0; $instIndex -lt $data.Count; $instIndex++) {
        $instruction = $data[$instIndex]
        $state.Direction = ($state.Direction + ($instruction.Turn -eq "R" ? 1 : -1)) % 4
        $state.Direction = ($state.Direction -eq -1) ? 3 : $state.Direction
        for ($i = 0; $i -lt $instruction.Distance; $i++) {
            switch ($state.Direction) {
                0 { $state.Lat += 1 }
                1 { $state.Long += 1 }
                2 { $state.Lat -= 1 }
                3 { $state.Long -= 1 }
            }
            if ($locationsVisisted.ContainsKey("$($state.Lat).$($state.Long)")) {
                #We've been here before, we're done
                [Math]::Abs($state.Lat) + [Math]::Abs($state.Long)
                $done = $true
                break
            }
            else {
                $locationsVisisted.Add("$($state.Lat).$($state.Long)", 1)
            }
        }
        if($done){break}
    }
}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/part2_test1.txt" 4
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 2: $result" -ForegroundColor Magenta

